import os
import tempfile
import base64
import time
from enum import Enum
from typing import Optional, Dict, Any

import cv2
import firebase_admin
from firebase_admin import credentials, firestore, storage
from openai import OpenAI
from google.cloud import storage as google_storage
from dotenv import load_dotenv
import firebase_functions

# Try to load from .env first (local development)
load_dotenv()

def get_openai_client():
    """Get OpenAI client with proper API key"""
    try:
        # Try Firebase config first
        config = firebase_functions.get_config()
        print("Firebase config:", config)
        openai_key = config.get('openai', {}).get('api_key')
        if not openai_key:
            # Try direct environment variable
            openai_key = os.getenv('OPENAI_API_KEY')
            print("Using env var for OpenAI key")
    except Exception as e:
        print(f"Error getting Firebase config: {str(e)}")
        # Fallback to env var
        openai_key = os.getenv('OPENAI_API_KEY')

    if not openai_key:
        raise ValueError("OPENAI_API_KEY must be set in Firebase config or environment")

    return OpenAI(api_key=openai_key)

class SummaryStatus(str, Enum):
    PENDING = 'pending'
    PROCESSING = 'processing'
    COMPLETED = 'completed'
    ERROR = 'error'

def extract_frames(video_path: str, output_dir: str) -> list[str]:
    """
    Extracts I-frames from video using ffmpeg and returns list of frame paths
    """
    # Use ffmpeg to extract I-frames
    os.system(f'ffmpeg -i "{video_path}" -vf "select=\'eq(pict_type,PICT_TYPE_I)\'" -vsync vfr -f image2 "{output_dir}/frame-%04d.jpg"')
    
    # Get list of generated frame paths
    frames = [f for f in os.listdir(output_dir) if f.endswith('.jpg')]
    frames.sort()  # Ensure frames are in order
    
    return [os.path.join(output_dir, f) for f in frames]

async def update_summary_status(video_id: str, status: SummaryStatus, error: Optional[str] = None) -> None:
    """
    Updates the summary status in Firestore
    """
    db = firestore.client()
    doc_ref = db.collection('videos').document(video_id)
    
    update_data = {
        'summary.status': status.value,
        'summary.updatedAt': firestore.SERVER_TIMESTAMP
    }
    
    if error:
        update_data['summary.error'] = error
    
    await doc_ref.update(update_data)

def generate_summary(frames: list[str], max_frames: int = 248) -> Dict[str, str]:
    """
    Generates video summary using OpenAI's GPT-4 Vision
    """
    # Convert frames to base64 and sample if needed
    base64_frames = []
    interval = max(1, len(frames) // max_frames)
    
    for frame_path in frames[::interval]:
        with open(frame_path, 'rb') as f:
            img_data = f.read()
            base64_frames.append(base64.b64encode(img_data).decode('utf-8'))

    # Prepare prompt for OpenAI
    messages = [{
        "role": "user",
        "content": [
            "Generate two descriptions for this video: a short 1-2 sentence summary and a detailed paragraph.",
            *map(lambda x: {"image": x, "resize": 768}, base64_frames),
        ],
    }]

    # Call OpenAI with exponential retry
    max_retries = 3
    base_delay = 1
    
    for attempt in range(max_retries):
        try:
            response = client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=500
            )
            
            # Parse response into short and detailed descriptions
            content = response.choices[0].message.content
            parts = content.split('\n\n', 1)
            
            return {
                'shortDescription': parts[0].strip(),
                'detailedDescription': parts[1].strip() if len(parts) > 1 else parts[0].strip()
            }
            
        except Exception as e:
            if 'invalid_api_key' in str(e).lower() or 'expired' in str(e).lower():
                raise  # Don't retry auth errors
                
            if attempt == max_retries - 1:
                raise  # Last attempt failed
                
            delay = base_delay * (2 ** attempt)  # Exponential backoff
            time.sleep(delay)

async def process_video(event: Dict[str, Any], context: Any) -> None:
    """
    Cloud Function triggered by new video upload
    """
    # Initialize OpenAI client when function runs
    client = get_openai_client()
    
    try:
        file_path = event['name']
        video_id = file_path.split('/')[1]  # Assuming path: videos/{videoId}/original.mov
        
        if not file_path.endswith('original.mov'):
            return  # Only process original video uploads
            
        await update_summary_status(video_id, SummaryStatus.PROCESSING)
        
        # Create temporary directory for frame extraction
        with tempfile.TemporaryDirectory() as temp_dir:
            # Download video file
            bucket = storage.bucket()
            video_blob = bucket.blob(file_path)
            temp_video_path = os.path.join(temp_dir, 'video.mov')
            video_blob.download_to_filename(temp_video_path)
            
            # Extract frames
            frame_paths = extract_frames(temp_video_path, temp_dir)
            
            # Upload frames to Cloud Storage
            frames_dir = f'videos/{video_id}/frames'
            for frame_path in frame_paths:
                frame_name = os.path.basename(frame_path)
                frame_blob = bucket.blob(f'{frames_dir}/{frame_name}')
                frame_blob.upload_from_filename(frame_path)
            
            # Generate summary
            summary = generate_summary(frame_paths)
            
            # Update Firestore
            db = firestore.client()
            doc_ref = db.collection('videos').document(video_id)
            await doc_ref.update({
                'summary.status': SummaryStatus.COMPLETED.value,
                'summary.shortDescription': summary['shortDescription'],
                'summary.detailedDescription': summary['detailedDescription'],
                'summary.updatedAt': firestore.SERVER_TIMESTAMP
            })
            
            # # Cleanup frames
            # for blob in bucket.list_blobs(prefix=frames_dir):
            #     blob.delete()
                
    except Exception as e:
        print(f"Error processing video {video_id}: {str(e)}")
        await update_summary_status(video_id, SummaryStatus.ERROR, str(e))
        raise 

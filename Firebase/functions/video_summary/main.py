# main.py

import os
import json
import logging
import tempfile
import base64
import time
import cv2
import firebase_admin
from firebase_admin import firestore, storage
from firebase_functions import storage_fn
from firebase_functions.params import StringParam, SecretParam
from openai import OpenAI
from google.cloud import storage as google_storage

logger = logging.getLogger("video_summary")
logging.basicConfig(level=logging.INFO)

STORAGE_BUCKET = StringParam("STORAGE_BUCKET")
OPENAI_API_KEY = SecretParam("OPENAI_API_KEY")

openai_client = None

class SummaryStatus(str):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    ERROR = "error"

def get_openai_client():
    global openai_client
    if openai_client is not None:
        logger.info("Reusing existing OpenAI client")
        return openai_client
    key = os.environ.get("OPENAI_API_KEY")
    if not key:
        logger.error("OPENAI_API_KEY is missing from environment")
        raise ValueError("Missing OPENAI_API_KEY secret")
    logger.info("Creating new OpenAI client")
    openai_client = OpenAI(api_key=key)
    logger.info("OpenAI client created successfully")
    return openai_client

def update_summary_status(video_id: str, status: str, error: str = None) -> None:
    logger.info("Updating summary status for video_id=%s to %s, error=%s", video_id, status, error)
    db = firestore.client()
    doc_ref = db.collection("videos").document(video_id)
    data = {
        "summary": {
            "status": status,
            "updatedAt": firestore.SERVER_TIMESTAMP
        }
    }
    if error:
        data["summary"]["error"] = error
    result = doc_ref.set(data, merge=True)
    logger.info("Firestore update complete -> %s", result)

def extract_frames(video_path: str, output_dir: str) -> list[str]:
    logger.info("Extracting frames from video_path=%s into output_dir=%s", video_path, output_dir)
    cmd = (
        f'ffmpeg -i "{video_path}" '
        f'-vf "select=\'eq(pict_type,PICT_TYPE_I)\'" '
        f'-vsync vfr -f image2 "{output_dir}/frame-%04d.jpg"'
    )
    logger.info("Running ffmpeg command: %s", cmd)
    os.system(cmd)
    frames = [f for f in os.listdir(output_dir) if f.endswith(".jpg")]
    frames.sort()
    results = [os.path.join(output_dir, f) for f in frames]
    logger.info("Extracted frames: %s", results)
    return results

def generate_summary(frames: list[str], max_frames: int = 248) -> dict:
    logger.info("Generating summary for %d frames, max_frames=%d", len(frames), max_frames)
    base64_frames = []
    interval = max(1, len(frames) // max_frames)
    for frame_path in frames[::interval]:
        try:
            with open(frame_path, "rb") as f:
                img_data = f.read()
            base64_frames.append(base64.b64encode(img_data).decode("utf-8"))
        except Exception as e:
            logger.error("Error reading frame %s: %s", frame_path, e)
    messages = [
        {
            "role": "system",
            "content": (
                "You are an expert sports commentator providing live-play narration and analysis "
                "of competitive sports events. Deliver highly detailed, real-time insight that captures the "
                "speed, strategy, and excitement of the match. Emphasize the significance of key plays, "
                "and player emotions. Use broadcast-quality language akin to professional sports "
                "coverage. Return valid JSON with exactly two fields: shortDescription and detailedDescription."
            )
        },
        {
            "role": "user",
            "content": [
                "Please provide a two-sentence highlight capturing the most exciting action, "
                "and then a long-form commentary including player strategies, pivotal moments, "
                "and remarkable individual performances. Only return a JSON object "
                "with shortDescription and detailedDescription.",
                *map(lambda x: {"image": x, "resize": 768}, base64_frames),
            ]
        }
    ]
    logger.info("Calling OpenAI with %d frames", len(base64_frames))
    client = get_openai_client()
    retries = 3
    delay = 1
    for attempt in range(retries):
        try:
            logger.info("Attempt %d: requesting completion from OpenAI", attempt)
            resp = client.chat.completions.create(
                model="gpt-4o",
                messages=messages,
                max_tokens=1000,
                response_format={"type": "json_object"}
            )
            raw_text = resp.choices[0].message.content
            logger.info("OpenAI raw response: %s", raw_text)
            try:
                parsed_json = json.loads(raw_text)
            except json.JSONDecodeError as decode_err:
                logger.error("JSON decode error: %s", decode_err)
                if attempt < retries - 1:
                    wait_time = delay * (2 ** attempt)
                    logger.warning("Retrying in %ds after JSON decode failure", wait_time)
                    time.sleep(wait_time)
                    continue
                logger.warning("All attempts exhausted, returning placeholder summary")
                return {
                    "shortDescription": "No summary",
                    "detailedDescription": "No summary"
                }
            short_desc = parsed_json.get("shortDescription", "").strip()
            long_desc = parsed_json.get("detailedDescription", "").strip()
            if not short_desc or not long_desc:
                logger.warning(
                    "Parsed JSON is missing one or both fields. shortDescription=%s, detailedDescription=%s",
                    short_desc,
                    long_desc
                )
                if attempt < retries - 1:
                    wait_time = delay * (2 ** attempt)
                    logger.warning("Retrying in %ds due to missing fields", wait_time)
                    time.sleep(wait_time)
                    continue
                logger.warning("All attempts failed, returning placeholder summary")
                return {
                    "shortDescription": "No summary",
                    "detailedDescription": "No summary"
                }
            logger.info("Received valid JSON from OpenAI on attempt %d", attempt)
            return {
                "shortDescription": short_desc,
                "detailedDescription": long_desc
            }
        except Exception as exc:
            logger.error("generate_summary attempt %d exception: %s", attempt, exc)
            if attempt < retries - 1:
                wait_time = delay * (2 ** attempt)
                logger.warning("Retrying in %ds", wait_time)
                time.sleep(wait_time)
            else:
                logger.warning("All attempts failed, returning placeholder summary")
                return {
                    "shortDescription": "No summary",
                    "detailedDescription": "No summary"
                }

def process_video_impl(event_data: dict) -> str:
    bucket_name = os.environ.get("STORAGE_BUCKET")
    if not bucket_name:
        logger.error("STORAGE_BUCKET not set in environment")
        raise ValueError("STORAGE_BUCKET is missing")
    content_type = event_data.get("contentType", "")
    file_path = event_data.get("name", "")
    if not content_type:
        logger.error("No content_type found in event data")
        return "No content_type in event data"
    if not content_type.startswith("video/"):
        logger.info("Ignoring non-video contentType=%s", content_type)
        return "Not a video file"
    if not file_path:
        logger.error("No file_path in event data")
        return "Invalid event data"
    if not file_path.endswith("original.mov"):
        logger.info("Not an original.mov upload, ignoring: %s", file_path)
        return "Not an original video upload"
    parts = file_path.split("/")
    if len(parts) < 2:
        logger.error("Invalid path structure for file_path=%s", file_path)
        return "Invalid path structure"
    video_id = parts[1]
    logger.info("Extracted video_id=%s from file_path=%s", video_id, file_path)
    try:
        logger.info("Updating summary status to PROCESSING for video_id=%s", video_id)
        update_summary_status(video_id, SummaryStatus.PROCESSING)
        with tempfile.TemporaryDirectory() as tmp:
            logger.info("Created temporary directory: %s", tmp)
            bucket_ref = storage.bucket(bucket_name)
            logger.info("Using bucket_ref=%s", bucket_name)
            blob = bucket_ref.blob(file_path)
            local_video_path = os.path.join(tmp, "video.mov")
            logger.info("Downloading %s -> %s", file_path, local_video_path)
            blob.download_to_filename(local_video_path)
            logger.info("Download complete")
            frames = extract_frames(local_video_path, tmp)
            logger.info("Extracted %d frames for video_id=%s", len(frames), video_id)
            frames_dir = f"videos/{video_id}/frames"
            logger.info("Uploading frames to %s", frames_dir)
            for frm in frames:
                remote_path = f"{frames_dir}/{os.path.basename(frm)}"
                logger.info("Uploading frame %s -> %s", frm, remote_path)
                bucket_ref.blob(remote_path).upload_from_filename(frm)
            logger.info("Generating summary for video_id=%s", video_id)
            summary = generate_summary(frames)
            logger.info("Summary result: %s", summary)
            db = firestore.client()
            doc_ref = db.collection("videos").document(video_id)
            update_data = {
                "summary": {
                    "status": SummaryStatus.COMPLETED,
                    "shortDescription": summary["shortDescription"],
                    "detailedDescription": summary["detailedDescription"],
                    "updatedAt": firestore.SERVER_TIMESTAMP
                }
            }
            logger.info("Upserting existing Firestore doc with final summary: %s", update_data)
            write_result = doc_ref.set(update_data, merge=True)
            logger.info("Firestore doc upsert -> %s", write_result)
        logger.info("Video processed successfully for video_id=%s", video_id)
        return "Video processed successfully"
    except Exception as e:
        logger.error("Exception while processing video_id=%s: %s", video_id, e)
        try:
            update_summary_status(video_id, SummaryStatus.ERROR, str(e))
        except Exception as e2:
            logger.error("Failed update_summary_status after exception: %s", e2)
        return f"Error processing video: {str(e)}"

@storage_fn.on_object_finalized(bucket=STORAGE_BUCKET, secrets=[OPENAI_API_KEY])
def process_video_handler(raw_event):
    data_dict = {
        "bucket": getattr(raw_event.data, "bucket", None),
        "contentType": getattr(raw_event.data, "content_type", None),
        "name": getattr(raw_event.data, "name", None),
    }
    return process_video_impl(data_dict)

# Video Summary Function

An edge function that automatically generates summaries for uploaded videos using OpenAI's GPT-4 Vision API.

## Overview

This function is triggered when a video is uploaded to Firebase Storage. It:

1. Extracts I-frames from the video
2. Processes these frames through GPT-4 Vision
3. Generates both short and detailed descriptions
4. Updates the video document in Firestore with the results

## Technical Details

### Trigger

- Activates on: `google.storage.object.finalize`
- Path pattern: `videos/{videoId}/original.mov`

### Processing Steps

1. Video frame extraction using ffmpeg
2. Temporary storage of frames in Cloud Storage
3. Frame processing through OpenAI's GPT-4 Vision
4. Firestore document updates
5. Cleanup of temporary frames

### Storage Structure

```plaintext
videos/
  ├── {videoId}/
  │   ├── original.mov      # Original video
  │   ├── thumbnail.jpg     # Video thumbnail
  │   ├── frames/           # Temporary i-frames directory
  │   │   ├── frame-0001.jpg
  │   │   ├── frame-0002.jpg
  │   │   └── ...
```

### Firestore Document Structure

```typescript
interface VideoDocument {
  summary: {
    status: 'pending' | 'processing' | 'completed' | 'error';
    shortDescription?: string;    // 1-2 sentences
    detailedDescription?: string; // Longer paragraph
    error?: string;              // Error message if failed
    updatedAt: Timestamp;        // Last update time
  }
}
```

## Configuration

Required environment variables:

- `FIREBASE_STORAGE_BUCKET`: Your Firebase Storage bucket
- `OPENAI_API_KEY`: OpenAI API key for GPT-4 Vision
- `VIDEO_SUMMARY_MEMORY`: Memory allocation (default: 1024MB)
- `VIDEO_SUMMARY_TIMEOUT_SECONDS`: Maximum execution time (default: 540s)
- `VIDEO_SUMMARY_MAX_FRAMES`: Maximum frames to process (default: 248)

## Error Handling

- Implements exponential retry for OpenAI API calls
- Skips retry for authentication errors
- Updates Firestore with error status and message
- Cleans up temporary files even on failure

## Limitations

- Maximum video duration: 5 minutes
- Maximum frames processed: 248 (OpenAI limit)
- Memory limit: 1024MB
- Execution timeout: 540 seconds

## Development

1. Install dependencies:

    ```bash
    pip install -r requirements.txt
    ```

2. Set up environment variables:

    ```bash
    cp .env.example .env
    # Edit .env with your values
    ```

3. Deploy:

    ```bash
    firebase deploy --only functions:video-summary
    ```

## Testing

Run tests:

```bash
python -m pytest tests/
```

## Monitoring

Monitor function execution in:

- Firebase Console > Functions > Logs
- Firebase Console > Storage > videos/{videoId}/
- Firestore > videos collection > document status

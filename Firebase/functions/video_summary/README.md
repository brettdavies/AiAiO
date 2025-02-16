# Video Summary Function – README

This document provides an **overview** of the `@video_summary` edge function, explaining its **purpose**, **capabilities**, and basic **operational guidelines**. While focused on a general engineering audience, it is written to help anyone—from product managers to developers—quickly understand what the function does, how it integrates with your Firebase project, and how it can be configured.

---

## Table of Contents

- [Video Summary Function – README](#video-summary-function--readme)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Key Responsibilities](#key-responsibilities)
  - [Workflow \& Trigger](#workflow--trigger)
  - [Environment Variables](#environment-variables)
  - [Features \& Limitations](#features--limitations)
  - [Error Handling](#error-handling)
  - [Deployment \& Configuration](#deployment--configuration)
  - [Testing](#testing)
  - [Monitoring](#monitoring)
  - [Feedback \& Support](#feedback--support)

---

## Overview

The **Video Summary Function** is a serverless approach to automating video analysis and content generation within your Firebase environment. It is triggered whenever a new video is uploaded to Firebase Storage. The function:

- Extracts key frames (I-frames) from the video.  
- Sends these frames to a cloud-based AI pipeline (OpenAI GPT-4 or similar) to produce a short and detailed **analysis** or **commentary**.  
- Updates the video’s Firestore document with the newly generated summaries.  
- Applies robust error handling and logging to ensure consistent execution.

The outcome is a set of textual summaries—short “highlight” text and a longer, more detailed “commentary.” This data is typically used to enhance user engagement by automating descriptions or providing quick overviews of uploaded videos (e.g., game footage, sports recaps, or educational content).

---

## Key Responsibilities

1. **Frame Extraction**  
   - Leverages ffmpeg to identify and extract I-frames.  
   - Saves frames in a Storage subdirectory, keeping them available for AI analysis or debugging.

2. **AI-Driven Summaries**  
   - Sends extracted frames to a GPT-based model that returns **concise** and **detailed** textual insights.  
   - Retries if the model fails to parse or returns invalid JSON.

3. **Firestore Document Updates**  
   - Maintains the `summary` field in the matching video document.  
   - Updates status to “pending,” “processing,” “completed,” or “error” as needed.

4. **Logging & Error Handling**  
   - Consistently logs function progress for easy debugging.  
   - Catches OpenAI or network failures and writes corresponding errors to Firestore.

---

## Workflow & Trigger

1. **Trigger**:  
   - Activated on `google.storage.object.finalize` events for any new video in the `videos/{videoId}/original.mov` path.  

2. **Execution Flow**:  
   1. **Status Setting**: Once triggered, the function marks the Firestore `summary.status` as `processing`.  
   2. **Frame Extraction**: ffmpeg runs in the serverless environment to extract frames and stores them in a dedicated `/frames` subdirectory in Firebase Storage.  
   3. **AI Summaries**: Example calls to GPT-based endpoints, requesting short and long commentary.  
   4. **Update Firestore**: On success, final summary text is added to Firestore, with `summary.status = ‘completed’`.  
   5. **Error Handling**: If something fails, sets `summary.status = ‘error’` and logs the issue.

---

## Environment Variables

| Variable Name            | Description                                                           | Default / Example            |
|--------------------------|-----------------------------------------------------------------------|------------------------------|
| **FIREBASE_STORAGE_BUCKET** | Name of your Firebase Storage bucket                                 | `my-project-bucket`          |
| **OPENAI_API_KEY**       | API key for GPT-based summarization                                   | `sk-xxxxxxxxxxxxxxxx`        |
| **VIDEO_SUMMARY_MEMORY** | (Optional) Memory allocation for this function (in MB)               | `1024`                       |
| **VIDEO_SUMMARY_TIMEOUT_SECONDS** | (Optional) Max execution time (in seconds)                   | `540`                        |
| **VIDEO_SUMMARY_MAX_FRAMES**     | (Optional) Maximum frames to process from a single video      | `248`                        |

> **Note**: Additional environment variables or custom function parameters can be defined for your specific AI service or logging requirements.

---

## Features & Limitations

- **Features**  
  - **Lightweight**: Runs seamlessly as a serverless Firebase Function, requiring no long-lived resources.  
  - **AI Customization**: Use your choice of AI service for summarization, with pluggable logic if you want to switch from GPT-4 to a different model.  
  - **Configurable**: Adjust the maximum frames or the memory/time limits for the function to best handle your video lengths and concurrency.

- **Limitations**  
  - **Video Duration**: With a max of 540 seconds (9 minutes) total execution time, function might fail on very large or lengthy videos (over 5–10 minutes).  
  - **Memory Constraints**: The default 1024MB limits your concurrency with tasks like ffmpeg extraction or large AI responses.  
  - **AI Costs**: Each AI invocation typically has usage-based fees. Keep track of your usage in the relevant AI provider’s dashboard.  
  - **Dependency on External APIs**: If external AI services degrade in performance or encounter downtime, the function’s performance will degrade as well.

---

## Error Handling

- **Transient Failures**  
  - The function retries AI calls up to a predefined limit when encountering timeouts or invalid responses.  
- **Firestore Updates**  
  - Sets the `summary.error` field on the video document.  
  - Skips excessive re-attempts to avoid infinite loops.  
- **Logging & Monitoring**  
  - Detailed logs in the Firebase console, making it easier to detect repeated breakdowns or usage patterns.

---

## Deployment & Configuration

1. **Firebase CLI**  
   - Deploy with `firebase deploy --only functions:video-summary`.  
   - Update your `function.yaml` if you need to change memory or time limits.  

2. **Environment Setup**  
   - Ensure your environment variables are set in either the [Firebase Functions Config](https://firebase.google.com/docs/functions/config-env) or `.env` reference.  
   - Keep secrets (like `OPENAI_API_KEY`) in your config store, not in version control.

3. **Security Rules**  
   - Confirm that Firestore and Storage rules allow your function to read/write the relevant `videos/{videoId}` documents and frames subdirectory.  
   - No public access should be granted to sensitive data or private frames by default.

---

## Testing

- **Local Testing**  
  - Use the Firebase Emulator Suite (`firebase emulators:start`) to simulate finalizing a storage object.  
  - Provide dummy or small test videos to validate the summarization process.  
- **Unit Testing**  
  - For advanced tests, mock or stub out the AI calls.  
  - Validate that Firestore updates are performed as expected.  
- **Integration Testing**  
  - Upload staged videos to a dev/staging environment.  
  - Check logs and Firestore updates for correct statuses and summary text.

---

## Monitoring

- **Firebase Console**  
  - Look under Functions > Logs to monitor real-time function executions and error messages.  
  - Access Firestore > `videos` collection to see summaries and statuses.  
- **Error Alerts**  
  - Consider enabling error notifications for the function or logs using a third-party integration (e.g., Slack, Google Chat, or email alerts).

---

## Feedback & Support

If you have **questions**, **bugs**, or **feature requests** regarding the `@video_summary` function, here are ways to get help:

- **Raise a GitHub Issue**: Provide details about your environment, log snippets, and reproduction steps.  
- **Contact Maintainers**: If you have direct communication channels with the repository’s maintainers, feel free to consult them for urgent matters.  

Thank you for integrating the **Video Summary Function**! We hope it delivers streamlined, AI-powered descriptions and insights for your uploaded videos while preserving data security and user privacy.

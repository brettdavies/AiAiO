---
title: "Slice 5 Implementation Details"
version: "1.1.0"
last_updated: "2025-02-10"
description: "Cloud Functions triggered on video upload, generating AI-based metadata (face recognition, jersey detection, transcription)."
---

# Slice 5: AI-Enabled Metadata Creation

## Table of Contents

- [Slice 5: AI-Enabled Metadata Creation](#slice-5-ai-enabled-metadata-creation)
  - [Table of Contents](#table-of-contents)
  - [Goals of Slice 5](#goals-of-slice-5)
  - [Implementation Steps](#implementation-steps)
    - [Task 5.1 Cloud Function Setup](#task-51-cloud-function-setup)
    - [Task 5.2 AI Integration (Face/Jersey Detection, Transcription)](#task-52-ai-integration-facejersey-detection-transcription)
    - [Task 5.3 Metadata Storage in Firestore](#task-53-metadata-storage-in-firestore)
    - [Task 5.4 Linking with Roster Data](#task-54-linking-with-roster-data)
    - [Task 5.5 Logging \& Error Handling](#task-55-logging--error-handling)
    - [Task 5.6 Verification / Demo](#task-56-verification--demo)

---

## Goals of Slice 5

1. **Cloud Functions**: Trigger on video uploads to Firebase Storage.  
2. **AI Processing**: Generate metadata (transcription, face recognition, jersey detection).  
3. **Metadata Storage**: Save results (transcript, recognized faces, jersey #s) in Firestore.  
4. **Link with Group Roster**: If a recognized face matches a group’s known member, store that association.  
5. **Logging & Error Handling**: Record AI events in Cloud Functions logs, map failures to typed errors if needed.

---

## Implementation Steps

### Task 5.1 Cloud Function Setup

**Objective**: Configure a new Cloud Function (using TypeScript or JS) triggered by Storage.

1. **Step 1**: `feature/slice5-task5.1-function-setup`.  
2. **Step 2**: In `/Firebase/functions/src/index.ts`:
   - Use `functions.storage.object().onFinalize(async (object) => { ... })`.
   - Ensure the function only processes video files (check `object.contentType`).  
3. **Step 3**: Deploy via `firebase deploy --only functions --project dev` (CLI only).  
4. **Step 4**: Merge to `development` once local emulator test is successful.

**Definition of Done** (Machine-Readable):

- A new function triggers on video uploads (check `object.contentType`).
- Deployed using Firebase CLI, not console.
- PR merges after emulator validation.

---

### Task 5.2 AI Integration (Face/Jersey Detection, Transcription)

**Objective**: Call external AI services or your own ML model to extract face/jersey data and generate a text transcript from audio tracks.

1. **Step 1**: `feature/slice5-task5.2-ai-processing`.  
2. **Step 2**: In the finalizing function, retrieve the video from Storage (temp download).  
3. **Step 3**: Use an AI library or external API (e.g., `faceRecognitionAPI`, `speechToTextAPI`) to produce:
   - `recognizedFaces: [ { boundingBox, ??? } ]`
   - `jerseyNumbers: [ "7", "10", ... ]`
   - `transcript: "full text from the video’s audio"`
4. **Step 4**: Merge after local testing or partial stubs if the real AI API is not yet integrated.

**Definition of Done** (Machine-Readable):

- Cloud Function code calls external or local AI logic to generate face & jersey metadata plus transcripts.
- Code merges into `development` after testing in local or staging environment.

---

### Task 5.3 Metadata Storage in Firestore

**Objective**: Write the AI results to the corresponding video doc in `videos` collection.

1. **Step 1**: `feature/slice5-task5.3-metadata-firestore`.  
2. **Step 2**: Once AI processing finishes, update Firestore doc:

   ```jsonc
   {
     "videoSummary": "Short auto-generated summary",
     "transcript": "Some transcription text",
     "recognizedFaces": [ ... ],
     "recognizedJerseys": [ ... ],
     "processingStatus": "complete"
   }
   ```

3. **Step 3**: Merge after local emulator testing.

**Definition of Done** (Machine-Readable):

- Video doc in Firestore is updated with AI-generated metadata.
- Verified with local emulators or test environment.
- Merged to development on success.

---

### Task 5.4 Linking with Roster Data

**Objective**: If recognized face IDs or jersey #s match group rosters, store that association (e.g. “Child #7 is Jane from groupX”).

1. **Step 1**: `feature/slice5-task5.4-roster-links`.
2. **Step 2**: For each recognized face/jersey, compare with group.members in Firestore:
   - If a match is found, note that user’s ID in recognizedMembers.
3. **Step 3**: Merge after validation.

**Definition of Done** (Machine-Readable):

- Recognized faces/jersey #s are cross-referenced with group rosters.
- Document is updated to store recognized memberIds.
- Merged upon local test success.

---

### Task 5.5 Logging & Error Handling

**Objective**: Log AI events in Cloud Functions and handle errors gracefully.

1. **Step 1**: `feature/slice5-task5.5-ai-logging`.
2. **Step 2**: [AI] Starting face recognition for video: {videoId}, [AI] Transcription complete, etc.
3. **Step 3**: Catch AI call failures, log them as .error, possibly store a partial or “failed” status in Firestore.
4. **Step 4**: Merge after verifying logs appear in Cloud Functions emulator.

**Definition of Done** (Machine-Readable):

- AI steps have structured logs in the function code.
- Partial/failure states are handled and stored if the AI process fails.
- Code merges after successful local tests.

---

### Task 5.6 Verification / Demo

**Objective**: Confirm that upon video upload, the function runs AI tasks and updates Firestore with recognized data.

1. **Step 1**: `feature/slice5-task5.6-verification`.
2. **Step 2**: Upload a sample test video via the app.
   - Observe the function logs.
   - Confirm Firestore doc is updated with metadata.
3. **Step 3**: Merge to development on success.

**Definition of Done** (Machine-Readable):

- Verified end-to-end metadata creation in local/staging environment.
- Merged after logs and Firestore updates confirm correct AI results.

Estimated Timeline

- 5-7 Days depending on integration complexity with external AI or custom ML.

Next Steps After Slice 5

- Proceed to Slice 6 (Privacy & Access Control), refining rules so that only authorized group members see metadata.
- Optionally implement real-time UI updates indicating “Processing in progress,” etc.

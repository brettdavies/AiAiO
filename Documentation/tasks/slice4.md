---
title: "Slice 4 Implementation Details"
version: "1.1.0"
last_updated: "2025-02-10"
description: "Implement video selection, local caching (SwiftData), and attaching uploads to groups."
---

# Slice 4: Video Upload & Offline Caching

## Table of Contents

- [Slice 4: Video Upload \& Offline Caching](#slice-4-video-upload--offline-caching)
  - [Table of Contents](#table-of-contents)
  - [Goals of Slice 4](#goals-of-slice-4)
  - [Implementation Steps](#implementation-steps)
    - [Task 4.1 Video Selection/Recording UI](#task-41-video-selectionrecording-ui)
    - [Task 4.2 Client-Side Validations](#task-42-client-side-validations)
    - [Task 4.3 SwiftData Offline Caching](#task-43-swiftdata-offline-caching)
    - [Task 4.4 Associate Video with Groups](#task-44-associate-video-with-groups)
    - [Task 4.5 Logging \& Error Handling](#task-45-logging--error-handling)
    - [Task 4.6 Verification / Demo](#task-46-verification--demo)
- [**Slice 5: AI-Enabled Metadata Creation**](#slice-5-ai-enabled-metadata-creation)
  - [\`\`\`md](#md)
  - [description: "Cloud Functions triggered on video upload, generating AI-based metadata (face recognition, jersey detection, transcription)."](#description-cloud-functions-triggered-on-video-upload-generating-ai-based-metadata-face-recognition-jersey-detection-transcription)
- [Slice 5: AI-Enabled Metadata Creation](#slice-5-ai-enabled-metadata-creation-1)
  - [Table of Contents](#table-of-contents-1)
  - [Goals of Slice 5](#goals-of-slice-5)
  - [Implementation Steps](#implementation-steps-1)
    - [Task 5.1 Cloud Function Setup](#task-51-cloud-function-setup)
    - [Task 5.2 AI Integration (Face/Jersey Detection, Transcription)](#task-52-ai-integration-facejersey-detection-transcription)
    - [Task 5.3 Metadata Storage in Firestore](#task-53-metadata-storage-in-firestore)
- [**Slice 6: Privacy \& Access Control**](#slice-6-privacy--access-control)
  - [\`\`\`md](#md-1)
  - [description: "Strengthen zero-trust access to videos/metadata, ensuring only owners or group members can view relevant data."](#description-strengthen-zero-trust-access-to-videosmetadata-ensuring-only-owners-or-group-members-can-view-relevant-data)
- [Slice 6: Privacy \& Access Control](#slice-6-privacy--access-control-1)
  - [Table of Contents](#table-of-contents-2)
  - [Goals of Slice 6](#goals-of-slice-6)
  - [Implementation Steps](#implementation-steps-2)
    - [Task 6.1 Refined Security Rules for Video Metadata](#task-61-refined-security-rules-for-video-metadata)
- [**Slice 7: Testing \& QA**](#slice-7-testing--qa)
  - [\`\`\`md](#md-2)
  - [description: "Comprehensive testing (unit, integration, UI), concurrency checks, SwiftLint, all using local Firebase Emulators."](#description-comprehensive-testing-unit-integration-ui-concurrency-checks-swiftlint-all-using-local-firebase-emulators)
- [Slice 7: Testing \& QA](#slice-7-testing--qa-1)
  - [Table of Contents](#table-of-contents-3)
  - [Goals of Slice 7](#goals-of-slice-7)
  - [Implementation Steps](#implementation-steps-3)
    - [Task 7.1 Unit \& ViewModel Tests](#task-71-unit--viewmodel-tests)
    - [Task 7.2 Integration Tests with Firebase Emulators](#task-72-integration-tests-with-firebase-emulators)
    - [Task 7.3 UI Tests \& Snapshots](#task-73-ui-tests--snapshots)
    - [Task 7.4 SwiftLint \& Concurrency Checks](#task-74-swiftlint--concurrency-checks)
    - [Task 7.5 Verification / Demo](#task-75-verification--demo)
  - [Estimated Timeline](#estimated-timeline)
  - [Next Steps After Slice 7](#next-steps-after-slice-7)
  - [description: "Release a beta version via TestFlight or Firebase App Distribution, gather feedback, and finalize the MVP."](#description-release-a-beta-version-via-testflight-or-firebase-app-distribution-gather-feedback-and-finalize-the-mvp)
- [Slice 8: Deployment \& Beta Distribution](#slice-8-deployment--beta-distribution)
  - [Table of Contents](#table-of-contents-4)
  - [Goals of Slice 8](#goals-of-slice-8)
  - [Implementation Steps](#implementation-steps-4)
    - [Task 8.1 TestFlight or Firebase App Distribution Setup](#task-81-testflight-or-firebase-app-distribution-setup)
    - [Task 8.2 Production Project Rules/Config](#task-82-production-project-rulesconfig)
    - [Task 8.3 Beta Release \& Versioning](#task-83-beta-release--versioning)
    - [Task 8.4 Feedback \& Monitoring](#task-84-feedback--monitoring)
  - [Estimated Timeline](#estimated-timeline-1)
  - [Project Completion](#project-completion)

---

## Goals of Slice 4

1. **Video Selection & Recording**: Provide SwiftUI interfaces to pick a video from the photo library or record in-app.  
2. **Client-Side Validations**: Enforce max file size (e.g., 100MB) and video format checks.  
3. **Offline Caching**: Use SwiftData or a local database to store pending uploads when offline.  
4. **Group Association**: Link uploaded videos to one or more groups from Slice 3.  
5. **Logging**: Record each upload attempt, success, or failure with `UnifiedLogger`.

---

## Implementation Steps

### Task 4.1 Video Selection/Recording UI

**Objective**: Provide SwiftUI views to pick or record a video.

1. **Step 1**: `feature/slice4-task4.1-video-ui`.  
2. **Step 2**: In `/App/Video/Views/VideoUploadView.swift`:
   - Button(s) for “Select from library” or “Record new video.”  
   - Use Swift’s native APIs or a small SwiftPM library if needed (still no `package.json`).  
3. **Step 3**: Preview with mock data.  
4. **Step 4**: Merge after local testing.

**Definition of Done** (Machine-Readable):

- A SwiftUI screen for picking/recording videos exists.
- No Node/`package.json` usage, only Xcode SPM if external libs are used.
- Code merges with passing checks.

---

### Task 4.2 Client-Side Validations

**Objective**: Ensure video size/type checks before uploading to Firebase Storage.

1. **Step 1**: `feature/slice4-task4.2-validations`.  
2. **Step 2**: In `VideoUploadViewModel.swift`, implement checks:
   - If file > 100MB, throw `GlobalError.videoTooLarge`.  
   - If extension not in `.mp4`, `.mov`, etc., throw `GlobalError.unsupportedFormat`.  
3. **Step 3**: Show user-friendly errors on UI.  
4. **Step 4**: Merge after verifying local tests.

**Definition of Done** (Machine-Readable):

- Videos over 100MB or with unknown formats are rejected.
- Errors map to `GlobalError`.
- PR merges into `development` successfully.

---

### Task 4.3 SwiftData Offline Caching

**Objective**: Store pending uploads locally to retry when the device is online.

1. **Step 1**: `feature/slice4-task4.3-offline-caching`.  
2. **Step 2**: Create a local SwiftData entity, e.g. `PendingUpload`, storing:
   - local file path  
   - group associations  
   - upload status (pending, uploading, failed, complete)  
3. **Step 3**: On app startup or network reconnect, automatically try uploading pending items.  
   - Possibly use `DispatchQueue` or an async loop.
4. **Step 4**: Merge after local testing.

**Definition of Done** (Machine-Readable):

- A SwiftData model tracks pending uploads.
- The app retries uploads automatically when connectivity is restored.
- PR merges into `development` with tests passed.

---

### Task 4.4 Associate Video with Groups

**Objective**: Let the user pick which group(s) the video belongs to, storing references in Firestore.

1. **Step 1**: `feature/slice4-task4.4-video-group-links`.  
2. **Step 2**: In `VideoUploadView`, fetch user’s groups. Let them select one or more.  
3. **Step 3**: After a successful Firebase Storage upload, store doc in Firestore `videos` collection:

   ```jsonc
   {
     "ownerUID": "user123",
     "groupIds": ["groupA", "groupB"],
     "storagePath": "videos/...mp4"
   }
    ```

4. **Step 4**: Merge after emulator testing.

**Definition of Done** (Machine-Readable):

- Videos are linked to groups by ID in Firestore.
- Confirmed working with local emulators.
- Merged once CI checks pass.

---

### Task 4.5 Logging & Error Handling

**Objective**: Log all upload events and map errors to GlobalError.

1. **Step 1**: `feature/slice4-task4.5-upload-logging`.
2. **Step 2**: [VideoUpload] Upload started, [VideoUpload] Upload success, [VideoUpload] Upload error: ....
3. **Step 3**: For network failures, use GlobalError.networkFailure. For storage issues, GlobalError.storageError.
4. **Step 4**: Merge once tested locally.

**Definition of Done** (Machine-Readable):

- Each upload attempt logs start/success/failure.
- All errors are typed in GlobalError.
- Merged into development after checks.

---

### Task 4.6 Verification / Demo

**Objective**: Demonstrate a full end-to-end upload against local emulators, including offline scenario.

1. **Step 1**: `feature/slice4-task4.6-verification`.
2. **Step 2**: Attempt an upload while offline (simulate in iOS simulator or real device). Confirm it queues.
3. **Step 3**: Reconnect, watch the upload proceed automatically.
4. **Step 4**: Confirm group references in Firestore.
5. **Step 5**: Merge to development.

**Definition of Done** (Machine-Readable):

- Offline upload flows verified, group references stored, logs visible.
- Merged with successful tests.

Estimated Timeline

- 5-7 Days total, depending on complexity of SwiftData caching and video picking/recording features.

Next Steps After Slice 4

- Proceed to Slice 5 (AI-Enabled Metadata Creation), enabling Cloud Functions to process uploaded videos (face recognition, jersey detection, transcription).

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
  - [Development Process](#development-process)
  - [Goals of Slice 4](#goals-of-slice-4)
  - [Implementation Steps](#implementation-steps)
    - [Task 4.1 Video Selection/Recording UI](#task-41-video-selectionrecording-ui)
    - [Task 4.2 Client-Side Validations](#task-42-client-side-validations)
    - [Task 4.3 SwiftData Offline Caching](#task-43-swiftdata-offline-caching)
    - [Task 4.4 Associate Video with Groups](#task-44-associate-video-with-groups)
    - [Task 4.5 Logging \& Error Handling](#task-45-logging--error-handling)
    - [Task 4.6 Verification / Demo](#task-46-verification--demo)

---

## Development Process

Before starting any task:

1. **Review Required Documentation**
   - [Git Workflow Guidelines](../../.cursor/rules/git_workflow.mdc) - **REQUIRED** for all commits and PRs
   - [Swift Rules](../../.cursor/rules/swift-rules.mdc) - For Swift code
   - [Project Structure](../../.cursor/rules/project-structure.mdc) - For file organization

2. **Git Workflow Summary**
   - Create feature branch: `feature/slice4-task<N>-<description>`
   - Make atomic commits following [commit conventions](../git_workflow.md#commit-process)
   - Create PR with comprehensive description
   - Squash merge to development after review
   - Delete feature branch after merge

3. **Pull Request Requirements**
   - All tests must pass
   - Code must follow style guides
   - Changes must be atomic and focused
   - PR description must be detailed
   - Squash merge is required

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

**Objective**: Provide SwiftUI views to pick a video.

1. **Step 1**: `feature/slice4-task4.1-video-ui`.  
2. **Step 2**: In `/App/aiaio/aiaio/Video/Views/VideoUploadView.swift`:
   - Button(s) for "Select from library".
   - Use Swift's native APIs or a small SwiftPM library if needed (still no `package.json`).
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
2. **Step 2**: In `VideoUploadView`, fetch user's groups. Let them select one or more.  
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

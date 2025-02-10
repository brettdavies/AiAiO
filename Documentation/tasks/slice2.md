
---
title: "Slice 2 Implementation Details"
version: "1.1.0"
last_updated: "2025-02-10"
description: "Implement SwiftUI-based authentication (email/password), zero-trust Firestore/Storage rules, and integrate with Firebase CLI only."
---

# Slice 2: Authentication & Secure Access

## Table of Contents

- [Slice 2: Authentication \& Secure Access](#slice-2-authentication--secure-access)
  - [Table of Contents](#table-of-contents)
  - [Goals of Slice 2](#goals-of-slice-2)
  - [Implementation Steps](#implementation-steps)
    - [Task 2.1 Auth UI (Sign-up, Sign-in)](#task-21-auth-ui-sign-up-sign-in)
    - [Task 2.2 Firebase Auth Integration](#task-22-firebase-auth-integration)
    - [Task 2.3 Zero-Trust Security Rules (Phase 1)](#task-23-zero-trust-security-rules-phase-1)
    - [Task 2.4 Logging \& Error Handling for Auth](#task-24-logging--error-handling-for-auth)
    - [Task 2.5 Verification / Demo](#task-25-verification--demo)
- [**Slice 3: Group \& Roster Management**](#slice-3-group--roster-management)
  - [\`\`\`md](#md)
  - [description: "Create, edit, and manage groups in Firestore. Store child face data or jersey numbers for AI referencing."](#description-create-edit-and-manage-groups-in-firestore-store-child-face-data-or-jersey-numbers-for-ai-referencing)
- [Slice 3: Group \& Roster Management](#slice-3-group--roster-management-1)
  - [Table of Contents](#table-of-contents-1)
  - [Goals of Slice 3](#goals-of-slice-3)
  - [Implementation Steps](#implementation-steps-1)
    - [Task 3.1 Group UI (Create \& Edit)](#task-31-group-ui-create--edit)
    - [Task 3.2 Firestore Schema for Groups](#task-32-firestore-schema-for-groups)
- [**Slice 4: Video Upload \& Offline Caching**](#slice-4-video-upload--offline-caching)
  - [\`\`\`md](#md-1)
  - [description: "Implement video selection, local caching (SwiftData), and attaching uploads to groups."](#description-implement-video-selection-local-caching-swiftdata-and-attaching-uploads-to-groups)
- [Slice 4: Video Upload \& Offline Caching](#slice-4-video-upload--offline-caching-1)
  - [Table of Contents](#table-of-contents-2)
  - [Goals of Slice 4](#goals-of-slice-4)
  - [Implementation Steps](#implementation-steps-2)
    - [Task 4.1 Video Selection/Recording UI](#task-41-video-selectionrecording-ui)
    - [Task 4.2 Client-Side Validations](#task-42-client-side-validations)
    - [Task 4.3 SwiftData Offline Caching](#task-43-swiftdata-offline-caching)
    - [Task 4.4 Associate Video with Groups](#task-44-associate-video-with-groups)
- [**Slice 5: AI-Enabled Metadata Creation**](#slice-5-ai-enabled-metadata-creation)
  - [\`\`\`md](#md-2)
  - [description: "Cloud Functions triggered on video upload, generating AI-based metadata (face recognition, jersey detection, transcription)."](#description-cloud-functions-triggered-on-video-upload-generating-ai-based-metadata-face-recognition-jersey-detection-transcription)
- [Slice 5: AI-Enabled Metadata Creation](#slice-5-ai-enabled-metadata-creation-1)
  - [Table of Contents](#table-of-contents-3)
  - [Goals of Slice 5](#goals-of-slice-5)
  - [Implementation Steps](#implementation-steps-3)
    - [Task 5.1 Cloud Function Setup](#task-51-cloud-function-setup)
    - [Task 5.2 AI Integration (Face/Jersey Detection, Transcription)](#task-52-ai-integration-facejersey-detection-transcription)
    - [Task 5.3 Metadata Storage in Firestore](#task-53-metadata-storage-in-firestore)
- [**Slice 6: Privacy \& Access Control**](#slice-6-privacy--access-control)
  - [\`\`\`md](#md-3)
  - [description: "Strengthen zero-trust access to videos/metadata, ensuring only owners or group members can view relevant data."](#description-strengthen-zero-trust-access-to-videosmetadata-ensuring-only-owners-or-group-members-can-view-relevant-data)
- [Slice 6: Privacy \& Access Control](#slice-6-privacy--access-control-1)
  - [Table of Contents](#table-of-contents-4)
  - [Goals of Slice 6](#goals-of-slice-6)
  - [Implementation Steps](#implementation-steps-4)
    - [Task 6.1 Refined Security Rules for Video Metadata](#task-61-refined-security-rules-for-video-metadata)
- [**Slice 7: Testing \& QA**](#slice-7-testing--qa)
  - [\`\`\`md](#md-4)
  - [description: "Comprehensive testing (unit, integration, UI), concurrency checks, SwiftLint, all using local Firebase Emulators."](#description-comprehensive-testing-unit-integration-ui-concurrency-checks-swiftlint-all-using-local-firebase-emulators)
- [Slice 7: Testing \& QA](#slice-7-testing--qa-1)
  - [Table of Contents](#table-of-contents-5)
  - [Goals of Slice 7](#goals-of-slice-7)
  - [Implementation Steps](#implementation-steps-5)
    - [Task 7.1 Unit \& ViewModel Tests](#task-71-unit--viewmodel-tests)
    - [Task 7.2 Integration Tests with Firebase Emulators](#task-72-integration-tests-with-firebase-emulators)
    - [Task 7.3 UI Tests \& Snapshots](#task-73-ui-tests--snapshots)
    - [Task 7.4 SwiftLint \& Concurrency Checks](#task-74-swiftlint--concurrency-checks)
    - [Task 7.5 Verification / Demo](#task-75-verification--demo)
  - [Estimated Timeline](#estimated-timeline)
  - [Next Steps After Slice 7](#next-steps-after-slice-7)
  - [description: "Release a beta version via TestFlight or Firebase App Distribution, gather feedback, and finalize the MVP."](#description-release-a-beta-version-via-testflight-or-firebase-app-distribution-gather-feedback-and-finalize-the-mvp)
- [Slice 8: Deployment \& Beta Distribution](#slice-8-deployment--beta-distribution)
  - [Table of Contents](#table-of-contents-6)
  - [Goals of Slice 8](#goals-of-slice-8)
  - [Implementation Steps](#implementation-steps-6)
    - [Task 8.1 TestFlight or Firebase App Distribution Setup](#task-81-testflight-or-firebase-app-distribution-setup)
    - [Task 8.2 Production Project Rules/Config](#task-82-production-project-rulesconfig)
    - [Task 8.3 Beta Release \& Versioning](#task-83-beta-release--versioning)
    - [Task 8.4 Feedback \& Monitoring](#task-84-feedback--monitoring)
  - [Estimated Timeline](#estimated-timeline-1)
  - [Project Completion](#project-completion)

---

## Goals of Slice 2

1. **Auth UI**: Implement SwiftUI views for sign-up and sign-in with email/password.  
2. **Firebase Auth Integration**: Add Firebase iOS SDK calls, verifying credentials are sent to Firebase without manual console steps.  
3. **Zero-Trust Baseline**: Lock down Firestore and Storage so only authenticated users can read/write their own data.  
4. **Logging & Error Handling**: Continue using `UnifiedLogger` and `GlobalError` for sign-in, sign-up, and potential errors (e.g., `invalidEmail`, `weakPassword`).

---

## Implementation Steps

### Task 2.1 Auth UI (Sign-up, Sign-in)

**Objective**: Create SwiftUI screens for sign-up and sign-in flows.

1. **Step 1**: Branch off `development` as `feature/slice2-task2.1-auth-ui`.  
2. **Step 2**: In `/App/Auth/Views/`, create `SignInView.swift` and `SignUpView.swift`:
   - Minimal UI: email + password fields, sign-in/up buttons.  
   - SwiftUI previews with mock ViewModels for local development.
3. **Step 3**: Add navigation from a root view (e.g., show SignInView if not logged in).  
4. **Step 4**: Push changes, open PR to `development`, merge after CI passes.

**Definition of Done** (Machine-Readable):

- Two SwiftUI screens (SignInView, SignUpView) exist in the `Auth/Views` folder.
- Each has a SwiftUI preview using mock data.
- Code merges into `development` successfully with no console-based modifications.

---

### Task 2.2 Firebase Auth Integration

**Objective**: Use the Firebase iOS SDK (installed via Xcode SPM) for email/password sign-up and sign-in.

1. **Step 1**: Create branch `feature/slice2-task2.2-auth-integration`.  
2. **Step 2**: In `/App/Auth/ViewModels/AuthViewModel.swift`, add async methods:
   - `signIn(email: String, password: String) async throws`
   - `signUp(email: String, password: String) async throws`
3. **Step 3**: Invoke Firebase Auth SDK calls, e.g.:

   ```swift
   try await Auth.auth().createUser(withEmail: email, password: password)
   ```

4. **Step 4**: On success/failure, map errors to GlobalError (e.g., invalidEmail, weakPassword).
5. **Step 5**: In SignInView / SignUpView, call these ViewModel methods on button taps.
6. **Step 6**: Test with the local Auth emulator (firebase emulators:start).
7. **Step 7**: Merge into development once tested.

**Definition of Done** (Machine-Readable):

- Auth flow is functional against local Auth emulator (no manual console usage).
- `signIn` and `signUp` calls handle errors via `GlobalError`.
- Merged to `development` after successful PR checks.

---

### Task 2.3 Zero-Trust Security Rules (Phase 1)

**Objective**: Restrict Firestore and Storage so only authenticated users can access data. All updates must be done via Firebase CLI.

1. **Step 1**: Create branch `feature/slice2-task2.3-zero-trust-rules`.
2. **Step 2**: In `/Firebase/SecurityRules/firestore.rules`, enforce:

```swift
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

(Minimal requirement: Must be authenticated.)

3. **Step 3**: In `/Firebase/SecurityRules/storage.rules`, do similarly:

```swift
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

4. **Step 4**: Deploy these rules via Firebase CLI:

```bash
firebase deploy --only firestore:rules,storage:rules --project dev
```

(Never via console.)

5. **Step 5**: Merge into development once emulator tests confirm restricted access for anonymous users.

**Definition of Done** (Machine-Readable):

- Firestore and Storage rules require `request.auth != null` for all operations.
- Rules are deployed using `firebase deploy --only (CLI), not manually.
- Branch merges to `development` after local emulator test passes.

---

### Task 2.4 Logging & Error Handling for Auth

**Objective**: Ensure sign-in/sign-up success/failure logs are captured, and all auth errors are mapped to GlobalError.

1. **Step 1**: Create branch `feature/slice2-task2.4-auth-logging`.
2. **Step 2**: In `AuthViewModel.swift`, log major events:

```swift
[Auth] Attempting sign-in with email
[Auth] Sign-in success or [Auth] Sign-in failed
```

3. **Step 3**: For error mapping, catch Firebase errors and convert them to GlobalError:

```swift
catch let err as NSError {
  if err.code == AuthErrorCode.invalidEmail.rawValue {
    throw GlobalError.invalidEmail
  } else {
    throw GlobalError.unknown(err.localizedDescription)
  }
}
```

4. **Step 4**: Merge to development after verifying logs appear in Xcode console.

**Definition of Done** (Machine-Readable):

- Auth flows log success/failure events with UnifiedLogger.
- Firebase errors are mapped to typed GlobalError cases.
- Merged to development after testing.

---

### Task 2.5 Verification / Demo

**Objective**: Validate sign-in and sign-up flows with the local emulator, ensuring zero-trust rules block anonymous access.

1. **Step 1**: Create branch `feature/slice2-task2.5-verification`.
2. **Step 2**: Run `firebase emulators:start`.
3. **Step 3**: Try sign-up with test email/password in SignUpView.
   - Verify user is created in the Auth emulator logs.
   - Confirm user can read/write from Firestore/Storage.
   - Confirm anonymous user is blocked (403 or permission denied).
4. **Step 4**: Merge into development upon success.

**Definition of Done** (Machine-Readable):

- Local testing verifies sign-up creates user in Auth emulator.
- Authenticated user can read/write to Firestore/Storage; anonymous user cannot.
- PR merged with successful checks.

---

Estimated Timeline

- 4-6 Days total. Each subtask is a separate branch merged into development.

Next Steps After Slice 2

- Proceed to Slice 3 (Group & Roster Management) to implement storing child info, face/jersey references, and advanced rules.
- Continue zero-trust approach by refining rules in subsequent slices.

---
title: "Slice 3 Implementation Details"
version: "1.1.0"
last_updated: "2025-02-10"
description: "Create, edit, and manage groups in Firestore. Store child face data or jersey numbers for AI referencing."
---

# Slice 3: Group & Roster Management

## Table of Contents

- [Slice 3: Group \& Roster Management](#slice-3-group--roster-management)
  - [Table of Contents](#table-of-contents)
  - [Goals of Slice 3](#goals-of-slice-3)
  - [Implementation Steps](#implementation-steps)
    - [Task 3.1 Group UI (Create \& Edit)](#task-31-group-ui-create--edit)
    - [Task 3.2 Firestore Schema for Groups](#task-32-firestore-schema-for-groups)
    - [Task 3.3 Roster Data (Faces, Jersey Numbers)](#task-33-roster-data-faces-jersey-numbers)
    - [Task 3.4 Security Rules (Phase 2)](#task-34-security-rules-phase-2)
    - [Task 3.5 Logging \& Error Handling](#task-35-logging--error-handling)
    - [Task 3.6 Verification / Demo](#task-36-verification--demo)
- [**Slice 4: Video Upload \& Offline Caching**](#slice-4-video-upload--offline-caching)
  - [\`\`\`md](#md)
  - [description: "Implement video selection, local caching (SwiftData), and attaching uploads to groups."](#description-implement-video-selection-local-caching-swiftdata-and-attaching-uploads-to-groups)
- [Slice 4: Video Upload \& Offline Caching](#slice-4-video-upload--offline-caching-1)
  - [Table of Contents](#table-of-contents-1)
  - [Goals of Slice 4](#goals-of-slice-4)
  - [Implementation Steps](#implementation-steps-1)
    - [Task 4.1 Video Selection/Recording UI](#task-41-video-selectionrecording-ui)
    - [Task 4.2 Client-Side Validations](#task-42-client-side-validations)
    - [Task 4.3 SwiftData Offline Caching](#task-43-swiftdata-offline-caching)
    - [Task 4.4 Associate Video with Groups](#task-44-associate-video-with-groups)
- [**Slice 5: AI-Enabled Metadata Creation**](#slice-5-ai-enabled-metadata-creation)
  - [\`\`\`md](#md-1)
  - [description: "Cloud Functions triggered on video upload, generating AI-based metadata (face recognition, jersey detection, transcription)."](#description-cloud-functions-triggered-on-video-upload-generating-ai-based-metadata-face-recognition-jersey-detection-transcription)
- [Slice 5: AI-Enabled Metadata Creation](#slice-5-ai-enabled-metadata-creation-1)
  - [Table of Contents](#table-of-contents-2)
  - [Goals of Slice 5](#goals-of-slice-5)
  - [Implementation Steps](#implementation-steps-2)
    - [Task 5.1 Cloud Function Setup](#task-51-cloud-function-setup)
    - [Task 5.2 AI Integration (Face/Jersey Detection, Transcription)](#task-52-ai-integration-facejersey-detection-transcription)
    - [Task 5.3 Metadata Storage in Firestore](#task-53-metadata-storage-in-firestore)
- [**Slice 6: Privacy \& Access Control**](#slice-6-privacy--access-control)
  - [\`\`\`md](#md-2)
  - [description: "Strengthen zero-trust access to videos/metadata, ensuring only owners or group members can view relevant data."](#description-strengthen-zero-trust-access-to-videosmetadata-ensuring-only-owners-or-group-members-can-view-relevant-data)
- [Slice 6: Privacy \& Access Control](#slice-6-privacy--access-control-1)
  - [Table of Contents](#table-of-contents-3)
  - [Goals of Slice 6](#goals-of-slice-6)
  - [Implementation Steps](#implementation-steps-3)
    - [Task 6.1 Refined Security Rules for Video Metadata](#task-61-refined-security-rules-for-video-metadata)
- [**Slice 7: Testing \& QA**](#slice-7-testing--qa)
  - [\`\`\`md](#md-3)
  - [description: "Comprehensive testing (unit, integration, UI), concurrency checks, SwiftLint, all using local Firebase Emulators."](#description-comprehensive-testing-unit-integration-ui-concurrency-checks-swiftlint-all-using-local-firebase-emulators)
- [Slice 7: Testing \& QA](#slice-7-testing--qa-1)
  - [Table of Contents](#table-of-contents-4)
  - [Goals of Slice 7](#goals-of-slice-7)
  - [Implementation Steps](#implementation-steps-4)
    - [Task 7.1 Unit \& ViewModel Tests](#task-71-unit--viewmodel-tests)
    - [Task 7.2 Integration Tests with Firebase Emulators](#task-72-integration-tests-with-firebase-emulators)
    - [Task 7.3 UI Tests \& Snapshots](#task-73-ui-tests--snapshots)
    - [Task 7.4 SwiftLint \& Concurrency Checks](#task-74-swiftlint--concurrency-checks)
    - [Task 7.5 Verification / Demo](#task-75-verification--demo)
  - [Estimated Timeline](#estimated-timeline)
  - [Next Steps After Slice 7](#next-steps-after-slice-7)
  - [description: "Release a beta version via TestFlight or Firebase App Distribution, gather feedback, and finalize the MVP."](#description-release-a-beta-version-via-testflight-or-firebase-app-distribution-gather-feedback-and-finalize-the-mvp)
- [Slice 8: Deployment \& Beta Distribution](#slice-8-deployment--beta-distribution)
  - [Table of Contents](#table-of-contents-5)
  - [Goals of Slice 8](#goals-of-slice-8)
  - [Implementation Steps](#implementation-steps-5)
    - [Task 8.1 TestFlight or Firebase App Distribution Setup](#task-81-testflight-or-firebase-app-distribution-setup)
    - [Task 8.2 Production Project Rules/Config](#task-82-production-project-rulesconfig)
    - [Task 8.3 Beta Release \& Versioning](#task-83-beta-release--versioning)
    - [Task 8.4 Feedback \& Monitoring](#task-84-feedback--monitoring)
  - [Estimated Timeline](#estimated-timeline-1)
  - [Project Completion](#project-completion)

---

## Goals of Slice 3

1. **Group Creation & Editing**: SwiftUI screens to create a new group (e.g., “U10 Soccer Team”).  
2. **Firestore Schema**: Store group documents with fields for roster members, each containing child info (name, face data, jersey #).  
3. **Security Rules**: Refine zero-trust so only group owners can edit their groups. Others get denied.  
4. **Logging & Error Handling**: Use `UnifiedLogger` and `GlobalError` for group creation, roster updates, or rule violations.

---

## Implementation Steps

### Task 3.1 Group UI (Create & Edit)

**Objective**: Provide SwiftUI views for creators to manage groups.

1. **Step 1**: Branch off `development` → `feature/slice3-task3.1-group-ui`.  
2. **Step 2**: In `/App/Groups/Views`, create `GroupListView.swift` and `GroupDetailView.swift`.  
   - `GroupListView` displays existing groups.  
   - `GroupDetailView` allows editing group name, short description, etc.  
3. **Step 3**: SwiftUI previews with mock data to confirm layout.  
4. **Step 4**: Merge to `development` after CI passes.

**Definition of Done** (Machine-Readable):

- Two SwiftUI views exist for group listing and detail/editing.
- They have functioning previews using mock data.
- Code merges into `development` successfully.

---

### Task 3.2 Firestore Schema for Groups

**Objective**: Define how groups are stored in Firestore (via CLI-based updates only).

1. **Step 1**: `feature/slice3-task3.2-group-schema` branch.  
2. **Step 2**: In `/App/Groups/Models/Group.swift`, define a struct:

   ```swift
   struct Group: Codable, Identifiable {
       var id: String
       var name: String
       var description: String
       // optional: creationDate, ownerUID, etc.
   }
   ```

3. **Step 3**: In `/App/Groups/ViewModels/GroupViewModel.swift`, implement Firestore CRUD using async/await:

   ```swift
   createGroup(_ group: Group) async throws
   fetchGroups() async throws -> [Group]
   ```

4. **Step 4**: Test with local emulator, verifying data is stored in groups collection.
5. **Step 5**: Merge to development.

**Definition of Done** (Machine-Readable):

- A Group model with Codable is defined.
- Firestore CRUD calls for groups are implemented using async/await.
- No manual console creation; only CLI + emulator.

---

### Task 3.3 Roster Data (Faces, Jersey Numbers)

**Objective**: Store per-member data (child name, face photo reference, jersey #) to assist future AI.

1. **Step 1**: `feature/slice3-task3.3-roster-data` branch.
2. **Step 2**: Extend Group or create a Member struct:

```swift
struct Member: Codable, Identifiable {
    var id: String
    var name: String
    var jerseyNumber: String?
    var facePhotoURL: String? // optional
}
```

3. **Step 3**: Possibly use a subcollection (groups/{groupID}/members/{memberID}) or embed in a single Group doc.
4. **Step 4**: SwiftUI forms in GroupDetailView to add/edit members.
5. **Step 5**: Merge once tested locally.

**Definition of Done** (Machine-Readable):

- A roster management form is present.
- Child data (face photo, jersey #) is stored in Firestore (subcollection or embedded).
- PR merges to development after local tests.

---

### Task 3.4 Security Rules (Phase 2)

**Objective**: Only group owners can create/edit a group or roster, others are denied.

1. **Step 1**: `feature/slice3-task3.4-rules-phase2` branch.
2. **Step 2**: In `/Firebase/SecurityRules/firestore.rules`, refine:

```swift
match /groups/{groupId} {
  allow create: if request.auth != null; // or request.auth.uid is group owner
  allow read: if request.auth != null;
  allow update, delete: if resource.data.ownerUID == request.auth.uid;
  match /members/{memberId} { ... }
}
```

3. **Step 3**: Deploy via `firebase deploy --only firestore:rules --project dev`.
4. **Step 4**: Merge after local emulator test.

**Definition of Done** (Machine-Readable):

- Only the group’s ownerUID can update the group doc.
- Rules deployed exclusively via Firebase CLI.
- Verified with local emulator before merging.

---

### Task 3.5 Logging & Error Handling

**Objective**: Extend UnifiedLogger usage for group creation, roster updates, etc.

1. **Step 1**: `feature/slice3-task3.5-group-logging` branch.
2. **Step 2**: Log events like `[Groups] Created new group: {id}`, `[Groups] Added member: {memberId}`.
3. **Step 3**: Convert rule rejections or Firestore errors into `GlobalError` (e.g., `.insufficientPermissions`).
4. **Step 4**: Merge after verifying logs and error mappings.

**Definition of Done** (Machine-Readable):

- Group operations produce logs.
- Firestore-related errors map to typed `GlobalError`.
- Merged to development successfully.

---

### Task 3.6 Verification / Demo

**Objective**: Demonstrate group/roster creation, security, and logs.

1. **Step 1**: `feature/slice3-task3.6-verification` branch.
2. **Step 2**: Using the local emulator, create a group as the signed-in user.
3. **Step 3**: Attempt updates from a different user (should fail).
4. **Step 4**: Confirm logs and error messages are correct.
5. **Step 5**: Merge into development upon success.

**Definition of Done** (Machine-Readable):

- Verified group creation flows, security constraints, logs, and error handling.
- Merged into development with passing CI checks.

Estimated Timeline

- 4-6 Days total. Roster management may take extra time if embedding vs. subcollections is chosen.

Next Steps After Slice 3

- Move on to Slice 4 (Video Upload & Offline Caching) to allow creators to attach videos to groups.
- Ensure group references are used in video metadata.

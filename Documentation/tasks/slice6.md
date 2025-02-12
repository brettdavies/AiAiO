---
title: "Slice 6 Implementation Details"
version: "1.1.0"
last_updated: "2025-02-10"
description: "Strengthen zero-trust access to videos/metadata, ensuring only owners or group members can view relevant data."
---

# Slice 6: Privacy & Access Control

## Table of Contents

- [Slice 6: Privacy \& Access Control](#slice-6-privacy--access-control)
  - [Table of Contents](#table-of-contents)
  - [Development Process](#development-process)
  - [Goals of Slice 6](#goals-of-slice-6)
  - [Implementation Steps](#implementation-steps)
    - [Task 6.1 Refined Security Rules for Video Metadata](#task-61-refined-security-rules-for-video-metadata)
    - [Task 6.2 Group-Based Whitelisting](#task-62-group-based-whitelisting)
    - [Task 6.3 Optional Face Blurring Stub](#task-63-optional-face-blurring-stub)
    - [Task 6.4 Logging \& Error Handling](#task-64-logging--error-handling)
    - [Task 6.5 Verification / Demo](#task-65-verification--demo)

## Development Process

Before starting any task:

1. **Review Required Documentation**
   - [Git Workflow Guidelines](../../.cursor/rules/git_workflow.mdc) - **REQUIRED** for all commits and PRs
   - [Swift Rules](../../.cursor/rules/swift-rules.mdc) - For Swift code
   - [Project Structure](../../.cursor/rules/project-structure.mdc) - For file organization

2. **Git Workflow Summary**
   - Create feature branch: `feature/slice6-task<N>-<description>`
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

## Goals of Slice 6

1. **Refined Security Rules**: Only owners or authorized group members can read video documents and AI metadata.  
2. **Group-Based Whitelisting**: If a user is in a group associated with a video, they get read access. Otherwise denied.  
3. **Optional Face Blurring Stub**: Possibly add a placeholder for blurring non-authorized faces (actual implementation can come later).  
4. **Zero-Trust**: Continue default "no access unless explicitly allowed."

---

## Implementation Steps

### Task 6.1 Refined Security Rules for Video Metadata

**Objective**: Restrict Firestore read access for `videos` to owners or group members.

1. **Step 1**: `feature/slice6-task6.1-video-rules`.  
2. **Step 2**: In `/Firebase/SecurityRules/firestore.rules`:

   ```plaintext
   match /videos/{videoId} {
     allow read: if request.auth.uid == resource.data.ownerUID
       || (resource.data.groupIds hasAny request.auth.token.groupMemberships);
     allow write: if request.auth.uid == resource.data.ownerUID;
   }
   ```

   (Implementation may vary; ensure it's CLI-deployed.)
3. **Step 3**: Merge after local emulator tests.

**Definition of Done** (Machine-Readable):

- videos can only be read by the owner or group members.
- Deployed via CLI, passing local emulator tests.
- Merged to development.

---

### Task 6.2 Group-Based Whitelisting

**Objective**: Ensure each user's Auth token or Firestore record includes their group memberships for whitelisting.

1. **Step 1**: `feature/slice6-task6.2-whitelisting`.
2. **Step 2**: If using custom claims, set request.auth.token.groupMemberships = [...] after sign-in or dynamically using a Cloud Function. Alternatively, store membership in Firestore and check via rules.
3. **Step 3**: Confirm logic matches the zero-trust model.
4. **Step 4**: Merge after local tests.

**Definition of Done** (Machine-Readable):

- Group membership is recognized in request.auth or validated in Firestore rules.
- No open data is accessible to non-members.
- Merged post emulator testing.

---

### Task 6.3 Optional Face Blurring Stub

**Objective**: Add a minimal placeholder for face-blurring logic if user is not authorized to see certain faces.

1. **Step 1**: `feature/slice6-task6.3-face-blur-stub`.
2. **Step 2**: Possibly in Cloud Functions, if AI detects a face not in any group roster, label it for future blurring.
3. **Step 3**: Add a UI note: "Faces for unauthorized children will be blurred in future implementation."
4. **Step 4**: Merge after partial testing.

**Definition of Done** (Machine-Readable):

- Code includes a placeholder for face-blurring. Actual blur can be a future step.
- Merged to development with no breakage.

---

### Task 6.4 Logging & Error Handling

**Objective**: Log access attempts, security rule rejections, and "insufficient permissions" errors.

1. **Step 1**: `feature/slice6-task6.4-logging`.
2. **Step 2**: For Cloud Functions, log unauthorized read attempts if you can catch them.
3. **Step 3**: In iOS app, handle 403 or "permission denied" as GlobalError.insufficientPermissions.
4. **Step 4**: Merge after verifying logs appear in local tests.

**Definition of Done** (Machine-Readable):

- Unauthorized reads/writes produce logs or errors.
- The app surfaces .insufficientPermissions for blocked requests.
- Merged successfully to development.

---

### Task 6.5 Verification / Demo

**Objective**: Confirm group-based whitelisting for videos and partial face-blur logic.

1. **Step 1**: `feature/slice6-task6.5-verification`.
2. **Step 2**: Sign in as userA, upload a video with group groupX.
   - Sign in as userB in the same group → can read video.
   - Sign in as userC in a different group → blocked.
3. **Step 3**: Merge after local emulator passes.

**Definition of Done** (Machine-Readable):

- Verified group-based access works. Non-members cannot read the video doc.
- Merged post successful testing.

Estimated Timeline

- 3-5 Days. Adding face blur logic stubs is optional but likely straightforward.

Next Steps After Slice 6

- Slice 7: Testing & QA, focusing on unit/integration/UI tests, concurrency checks, and coverage.
- Slice 8: Deploy a Beta build (TestFlight or Firebase App Distribution), gather feedback.

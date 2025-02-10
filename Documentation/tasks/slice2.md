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
  - [Development Process](#development-process)
  - [Implementation Steps](#implementation-steps)
    - [Task 2.1 Auth UI (Sign-up, Sign-in)](#task-21-auth-ui-sign-up-sign-in)
    - [Task 2.2 Firebase Auth Integration](#task-22-firebase-auth-integration)
    - [Task 2.3 Zero-Trust Security Rules (Phase 1)](#task-23-zero-trust-security-rules-phase-1)
    - [Task 2.4 Logging \& Error Handling for Auth](#task-24-logging--error-handling-for-auth)
    - [Task 2.5 Verification / Demo](#task-25-verification--demo)

---

## Goals of Slice 2

1. **Auth UI**: Implement SwiftUI views for sign-up and sign-in with email/password.  
2. **Firebase Auth Integration**: Add Firebase iOS SDK calls, verifying credentials are sent to Firebase without manual console steps.  
3. **Zero-Trust Baseline**: Lock down Firestore and Storage so only authenticated users can read/write their own data.  
4. **Logging & Error Handling**: Continue using `UnifiedLogger` and `GlobalError` for sign-in, sign-up, and potential errors (e.g., `invalidEmail`, `weakPassword`).

---

## Development Process

Before starting any task:

1. **Review Required Documentation**
   - [Git Workflow Guidelines](../../.cursor/rules/git_workflow.mdc) - **REQUIRED** for all commits and PRs
   - [Swift Rules](../../.cursor/rules/swift-rules.mdc) - For Swift code
   - [Project Structure](../../.cursor/rules/project-structure.mdc) - For file organization

2. **Git Workflow Summary**
   - Create feature branch: `feature/slice2-task<N>-<description>`
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
2. **Step 2**: In `/Firebase/SecurityRules/firestore.rules`, enforce

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

3. **Step 3**: In `/Firebase/SecurityRules/storage.rules`, do similarly

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

4. **Step 4**: Deploy these rules via Firebase CLI

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

3. **Step 3**: For error mapping, catch Firebase errors and convert them to GlobalError

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

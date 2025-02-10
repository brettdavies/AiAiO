---
title: "Slice 1 Implementation Details"
version: "1.1.0"
last_updated: "2025-02-10"
description: "Step-by-step tasks for establishing AiAiO’s foundation with a mono-repo, environment configs, local testing, and logging."
---

# Slice 1: Foundation & Project Setup

## Table of Contents

- [Slice 1: Foundation \& Project Setup](#slice-1-foundation--project-setup)
  - [Table of Contents](#table-of-contents)
  - [Goals of Slice 1](#goals-of-slice-1)
  - [Implementation Steps](#implementation-steps)
    - [Task 1.1 Initialize the Mono-Repo](#task-11-initialize-the-mono-repo)
    - [Task 1.2 Setup `/App` Directory](#task-12-setup-app-directory)
    - [Task 1.3 Setup `/Firebase` Directory](#task-13-setup-firebase-directory)
    - [Task 1.4 UnifiedLogger \& GlobalError Enum](#task-14-unifiedlogger--globalerror-enum)
    - [Task 1.5 CI/CD Pipeline](#task-15-cicd-pipeline)
    - [Task 1.6 Verification / Demo](#task-16-verification--demo)
  - [Estimated Timeline](#estimated-timeline)
  - [Next Steps After Slice 1](#next-steps-after-slice-1)

---

## Goals of Slice 1

1. **Mono-Repo Initialization**: Create `/App` (SwiftUI client) and `/Firebase` (backend) using **Git** + **Firebase CLI** for all provisioning steps.  
2. **Environment Config & Local Emulators**: Enable dev/prod environment variables; use CLI-based commands for emulators, not manual dashboard settings.  
3. **Logging & Global Error Handling**: Implement `UnifiedLogger` in Swift (Xcode package manager only) and minimal logging in Cloud Functions. Create a typed `GlobalError` enum.  
4. **CI/CD & Testing Scaffold**: Use GitHub Actions or similar, ensuring each step is done in an isolated branch, merged into `development` only after tests pass.

---

## Implementation Steps

### Task 1.1 Initialize the Mono-Repo

**Objective**: Configure a Git repository and top-level directory structure.

1. **Step 1**: Create a new remote repository on GitHub (or another service).  
2. **Step 2**: Clone the empty repo locally.  
3. **Step 3**: Create a branch `feature/slice1-task1.1-monorepo` from `development`.  
4. **Step 4**: Add top-level `.gitignore` (excluding environment files, build artifacts, Node modules if present—but we do not use Node-based builds).  
5. **Step 5**: Create a `README.md` referencing the main project plan (`project_plan.md`) and style guides (`swift-rule.md`, `repository_structure.md`).  
6. **Step 6**: Commit changes and push the branch. Create a pull request into `development`. After passing CI checks, merge.

**Definition of Done** (Machine-Readable):

- A `mono-repo` structure is established with `/App` and `/Firebase` directories.
- `.gitignore` excludes all known secret files and build artifacts.
- `README.md` references the relevant documentation files.
- The branch is merged to `development` after checks pass.

---

### Task 1.2 Setup `/App` Directory

**Objective**: Create the iOS SwiftUI project using Xcode’s internal package manager for Firebase iOS SDK integration.

1. **Step 1**: From `development`, create a new branch `feature/slice1-task1.2-appsetup`.  
2. **Step 2**: In Xcode, generate an iOS (iOS 18) SwiftUI project named `AiAiOApp`.  
   - Enable **Strict Concurrency Checking** under Build Settings.  
3. **Step 3**: Use **Xcode’s internal Swift Package Manager** to add `Firebase` dependencies (Auth, Firestore, Storage, etc.).  
4. **Step 4**: Confirm no `package.json` is created or used.  
5. **Step 5**: Add a placeholder SwiftUI file (`ContentView.swift`) with a minimal `Text("Hello AiAiO")`.  
6. **Step 6**: Integrate a basic environment config approach (e.g., `.xcconfig` with `FIREBASE_PROJECT_ID_DEV`, `FIREBASE_PROJECT_ID_PROD`).  
7. **Step 7**: Verify the app compiles. Push to the branch. Open a pull request into `development` and merge after CI checks pass.

**Definition of Done** (Machine-Readable):

- Xcode project (SwiftUI, iOS 18) with concurrency checks turned on.
- Firebase iOS SDK integrated exclusively via SwiftPM in Xcode (no manual packages).
- Minimal SwiftUI view compiles with environment-based `.xcconfig`.
- Merged into `development` successfully.

---

### Task 1.3 Setup `/Firebase` Directory

**Objective**: Configure Firebase for the backend, using only **Firebase CLI** to initialize and manage resources.

1. **Step 1**: Create branch `feature/slice1-task1.3-firebase`.  
2. **Step 2**: In the `/Firebase` directory, run `firebase init` selecting **Firestore**, **Functions**, **Emulators**, and **Storage**.  
   - Store auto-generated config in subfolders (`functions/`, `SecurityRules/`, etc.).  
   - No manual changes in Firebase console.  
3. **Step 3**: In the newly created `firebase.json`, enable local emulators for Auth, Firestore, and Storage.  
4. **Step 4**: Add or update `.firebaserc` to define dev/prod projects by alias (`dev`, `prod`).  
5. **Step 5**: Commit and push. Open a pull request into `development`. Merge after CI + local emulator tests pass.

**Definition of Done** (Machine-Readable):

- `firebase init` has generated the necessary config, stored locally in `/Firebase`.
- Emulators are fully configured in `firebase.json` for Auth, Firestore, and Storage.
- No manual console steps performed; only CLI-based changes.

---

### Task 1.4 UnifiedLogger & GlobalError Enum

**Objective**: Standardize logging and error handling across both the iOS app and Firebase Functions.

1. **Step 1**: Create branch `feature/slice1-task1.4-logger-errors`.  
2. **Step 2**: In `/App/Utilities/UnifiedLogger.swift`:
   - Define a logger with log levels: `.debug`, `.info`, `.warning`, `.error`.
   - Provide a method: `log(_ message: String, level: LogLevel, context: String?)`.
3. **Step 3**: In `/App/Utilities/GlobalError.swift`:
   - Implement a typed enum (e.g. `invalidEmail`, `networkFailure`, `unknown(String)`) conforming to `LocalizedError`.
4. **Step 4**: In `/Firebase/functions/index.js` (or TypeScript equivalent):
   - Add basic logging (e.g. `console.log`) for function invocation and errors.  
   - If advanced structured logging is needed, implement a small wrapper method.
5. **Step 5**: Add usage examples in `ContentView.swift` (e.g., log a test message on button tap).
6. **Step 6**: Merge into `development` after verifying the iOS app logs appear in Xcode console and Functions logs appear in local emulator output.

**Definition of Done** (Machine-Readable):

- `UnifiedLogger` is implemented in Swift with distinct log levels.
- `GlobalError` enum is implemented with typed cases.
- Minimal logging approach in Firebase Functions for consistent usage.
- All tested in local dev environment prior to merging.

---

### Task 1.5 CI/CD Pipeline

**Objective**: Establish a minimal GitHub Actions pipeline to automatically build, lint, and test the code.

1. **Step 1**: Create branch `feature/slice1-task1.5-cicd`.  
2. **Step 2**: In `.github/workflows/ci.yml`, configure the following steps:
   - **Checkout** the code.
   - **Install** Swift (latest stable) and the **Firebase CLI**.
   - **Build** the Xcode project in debug mode (with concurrency checks).
   - **Run** any existing tests or SwiftLint checks.
3. **Step 3**: Add a status badge to the root `README.md` referencing the CI workflow.  
4. **Step 4**: Merge to `development` after verifying the pipeline succeeds on PR.

**Definition of Done** (Machine-Readable):

- A GitHub Actions (or similar) workflow is present that checks out code, installs Swift + Firebase CLI, builds the iOS project, and runs tests/lint.
- A status badge is added to `README.md`.
- Merged to `development` upon success.

---

### Task 1.6 Verification / Demo

**Objective**: Validate the local environment, logging, and minimal CI pipeline.

1. **Step 1**: Create branch `feature/slice1-task1.6-verification`.  
2. **Step 2**: Locally run `firebase emulators:start` inside `/Firebase`.  
   - Launch the iOS app in Xcode, confirm it connects to the local emulator (Auth, Firestore, Storage).  
3. **Step 3**: Add a test button in `ContentView.swift` that logs a success message with `UnifiedLogger`.  
4. **Step 4**: Merge into `development` once the environment is confirmed stable and logs are visible in the Xcode console and CLI output.

**Definition of Done** (Machine-Readable):

- A short local run proving the emulators function, the app logs to Xcode console, and `GlobalError` usage is demonstrated.
- The code merges into `development` with all automated checks passing.

---

## Estimated Timeline

- **3-5 Days** total. Each subtask branch should be merged into `development` promptly after local tests and CI pass.

---

## Next Steps After Slice 1

- With the foundational structure, logging, environment, and CI established, proceed to **Slice 2 (Authentication & Secure Access)**.  
- Continue using the **branch-per-task** workflow.  
- Maintain reliance on **Firebase CLI** (not console) and **Xcode SPM** (no `package.json`) for all future expansions.

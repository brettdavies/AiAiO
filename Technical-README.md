# AiAiO – Technical README

**This document** targets both:

1. **Technical Leaders** evaluating AiAiO for potential integration.  
2. **Engineers** wanting to install, build, or extend the codebase.

Below you’ll find a consolidated overview of AiAiO’s platform architecture, operational considerations, and references to component-level technical readmes.

---

## Table of Contents

- [AiAiO – Technical README](#aiaio--technical-readme)
  - [Table of Contents](#table-of-contents)
  - [High-Level Architecture](#high-level-architecture)
  - [Why We Chose Firebase + SwiftUI](#why-we-chose-firebase--swiftui)
  - [Security \& Privacy Essentials](#security--privacy-essentials)
  - [Scalability \& Performance](#scalability--performance)
  - [Technical Breakdown](#technical-breakdown)
    - [iOS App (`App/`)](#ios-app-app)
    - [Firebase Backend (`Firebase/`)](#firebase-backend-firebase)
    - [Testing (`Tests/`)](#testing-tests)
    - [Documentation (`Docs/`)](#documentation-docs)
  - [Development \& Setup](#development--setup)
  - [AI Pipeline Overview](#ai-pipeline-overview)
  - [Code Guidelines \& Review Process](#code-guidelines--review-process)
  - [References to Sub-Technical Readmes](#references-to-sub-technical-readmes)
  - [Questions \& Support](#questions--support)

---

## High-Level Architecture

```mermaid
flowchart LR
    A([iOS App<br>(SwiftUI, Swift 6)]) <--> B([Firebase Auth/Firestore/Storage/Functions])
    B --> C([AI Pipeline<br>(Cloud Fn’s, ML Services)])
```

1. **Core iOS App** (SwiftUI + Swift 6):  
   - Real-time data sync, concurrency-enabled UI, secure video uploads, and user/team interactions.

2. **Firebase Backend**:  
   - **Auth** for secure sign-in flows.  
   - **Firestore** for metadata and real-time collaboration.  
   - **Storage** for videos and processed assets.  
   - **Cloud Functions** for AI tasks like summarizing or blurring faces.

3. **AI Pipeline**:  
   - Runs under serverless or containerized environments.  
   - Uses FFmpeg for frame extraction, then calls AI endpoints (e.g., GPT-based) to generate textual highlights or transcripts.

---

## Why We Chose Firebase + SwiftUI

- **SwiftUI**: Offers a clean, reactive development pattern for iOS. Seamless concurrency and modular architecture.  
- **Firebase**: Zero-to-minimal server management, out-of-the-box real-time updates, flexible scaling, robust Auth (email, 3rd-party, etc.).  
- **Serverless Infrastructure**: Quickly deploy and update functions without provisioning. Minimizes dev-ops overhead and scales automatically.

---

## Security & Privacy Essentials

- **Facial Blurring / AI-based Redaction**: Minimizes the risk of personal identification, especially for minors.  
- **Granular Access Rules**: Firestore rules and role-based privileges ensure only approved users see certain data (e.g., unblurred frames).  
- **TLS & At-Rest Encryption**: All network traffic is encrypted in transit; Firebase Storage and Firestore handle data encryption at rest.  
- **Zero-Trust Approach**: Even staff members need explicit permission to view certain user data.

---

## Scalability & Performance

- **Horizontal Scaling**: As usage grows, Firestore and Cloud Functions handle spikes automatically.  
- **Resource Offloading**: Resource-intensive tasks (video processing, AI inferences) run on Cloud Functions or external ML platforms.  
- **Swift Concurrency**: The front-end remains responsive by heavily leveraging `async/await` and `actors` for thread-safe operations.

---

## Technical Breakdown

### iOS App (`App/`)

- **Architecture**:  
  - MVVM with SwiftUI.  
  - Concurrency via `async/await`.  
  - Subfolders for features (e.g., Authentication, VideoUpload) and shared utilities.
- **Logging**:  
  - A `UnifiedLogger` replaces `print()` statements, supporting `.info`, `.warning`, `.error`.
- **Error Handling**:  
  - Centralized `GlobalError` enum for known error cases.  
  - Domain-specific errors remain in feature folders.
- **Localization**:  
  - `Localization/` storing `.lproj` directories for multi-language support.
- **Additional Guidance**: See [App/Technical-README.md](App/Technical-README.md)

### Firebase Backend (`Firebase/`)

- **Folder Structure**:  
  - `Functions/` for serverless code (Python or Node.js).  
  - `Config/` for environment configs (e.g., `firebase.json`, `.env` files).  
  - `SecurityRules/` for Firestore and Storage rules.  
  - `Emulators/` for local Firestore, Auth, and Storage emulation.
- **Key Functions**:  
  - Video Summaries, Face Blurring, etc.  
  - Triggered by Storage events on new video uploads.
- **Rules & Permissions**:  
  - Firestore/Storage rules to ensure only authorized viewing, highlighting, or unblurring.
- **Additional Guidance**: See [Firebase/Technical-README.md](Firebase/Technical-README.md)

### Testing (`Tests/`)

- **AppTests/**:  
  - Swift-based unit tests for logic and concurrency.  
  - Executed with Xcode’s test suite or `xcodebuild`.
- **IntegrationTests/**:  
  - Emulated Firebase environment tests (Auth, Firestore, Storage).
- **UITests/**:  
  - XCTest UI automation for sign-in, navigation, etc.

### Documentation (`Docs/`)

- **Design Specs**, **task breakdowns**, and higher-level user flows.  
- For code style and concurrency usage, see `swift-rules.mdc`.  
- For environment specifics or extended architecture details, see `project-structure.mdc` and `tech-stack.mdc`.

---

## Development & Setup

1. **Clone & Install**  
   - Retrieve the repository.  
   - Open `App/*.xcodeproj` in Xcode 15.2+.

2. **Firebase Emulators**  
   - In `Firebase/Emulators`, run `firebase emulators:start` to test Firestore, Auth, Storage locally.

3. **Tests**  
   - Run unit tests (`AppTests`) and UI tests (`UITests`) via Xcode or the command line.

4. **Branching & Commits**  
   - Follow [git-workflow.mdc](.cursor/rules/git-workflow.mdc).  
   - Create feature branches: `feature/sliceN-taskN.description`.

---

## AI Pipeline Overview

1. **Frame Extraction (FFmpeg)**  
   - On `videos/{videoId}/original.mov` finalize event, a Cloud Function extracts I-frames.  
   - Frames stored in a `/frames` subfolder.

2. **AI Summaries**  
   - Synchronous or async calls to GPT-based or other ML APIs.  
   - Generates short and long textual content—stored in Firestore’s `summary` fields.

3. **Cleanup**  
   - Optionally remove frames post-analysis to save storage costs.  
   - Error handling includes retries, partial updates, or storing `summary.error`.

---

## Code Guidelines & Review Process

1. **Style & Concurrency**  
   - Swift 6 concurrency, no `print()`, type hints, `UnifiedLogger` usage.  
   - Python-based or TypeScript-based Functions must follow PEP 8 or standard TS lint guidelines.

2. **Testing & CI**  
   - Use `pytest`, Xcode tests, or Node test suites as needed.  
   - Local emulator usage to validate end-to-end functionality.

3. **PR Reviews & Merges**  
   - PR from `feature/...` → `development`.  
   - CI run ensures all tests, concurrency checks, and lint pass.  
   - Upon approval, conduct squash merge, referencing [commit style guidelines](.cursor/rules/git-workflow.mdc).

---

## References to Sub-Technical Readmes

- **iOS App**: [App/Technical-README.md](App/Technical-README.md)  
  - Detailed explanation of SwiftUI modules, concurrency patterns, and local dev steps.

- **Firebase**: [Firebase/Technical-README.md](Firebase/Technical-README.md)  
  - Covers Firestore/Storage rules, emulator usage, and how to add or update Cloud Functions.

- **Video Summary Function**: [Firebase/functions/video_summary/Technical-README.md](Firebase/functions/video_summary/Technical-README.md)  
  - Deep dive on frame extraction, AI integration, advanced debug best practices, and FFmpeg usage.

---

## Questions & Support

- **Issues or Bugs**: Open a new GitHub issue with a descriptive title, reproduction steps, and relevant logs.  
- **Feature Requests**: Provide screenshots or mockups detailing desired changes or improvements.  
- **Contact**: For urgent matters, check the top-level [Docs/](Docs/) folder for maintainer info or community channels.

Thank you for reading the **AiAiO** Technical README. We encourage you to explore each sub-technical readme for deeper, domain-specific knowledge. If you have suggestions for improvement or want to propose a pull request, please follow our [Git Workflow Guidelines](.cursor/rules/git-workflow.mdc). Happy coding!

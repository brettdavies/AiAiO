# AiAiO – Technical README

This Technical README targets two audiences:

1. **Technical Leaders** evaluating AiAiO for potential integration within their organizations.  
2. **Engineers** looking to implement, extend, or contribute to AiAiO’s codebase.  

Below, you’ll find a detailed overview of AiAiO’s architecture, technology stack, and operational considerations, followed by in-depth guidance for developers who plan to install, build, or collaborate on the project.

---

## Table of Contents

- [AiAiO – Technical README](#aiaio--technical-readme)
  - [Table of Contents](#table-of-contents)
  - [For Technical Leaders](#for-technical-leaders)
    - [Platform \& Deployment Model](#platform--deployment-model)
      - [Why Firebase?](#why-firebase)
    - [Security \& Privacy Model](#security--privacy-model)
    - [Scalability \& Performance](#scalability--performance)
    - [System Architecture](#system-architecture)
    - [Key Integrations \& Dependencies](#key-integrations--dependencies)
    - [Roadmap Considerations](#roadmap-considerations)
  - [For Engineers](#for-engineers)
    - [Repository Structure](#repository-structure)
    - [Environment \& Configuration](#environment--configuration)
    - [Local Development \& Testing](#local-development--testing)
    - [AI Pipeline Overview](#ai-pipeline-overview)
    - [Code Organization \& Best Practices](#code-organization--best-practices)
    - [Pull Request \& Review Process](#pull-request--review-process)

---

## For Technical Leaders

### Platform & Deployment Model

- **iOS Native App**: Built with SwiftUI (iOS 18.2+), leveraging Swift 6 concurrency features for better performance and responsiveness.  
- **Backend**: Primarily reliant on Firebase (Auth, Firestore, Storage, Functions), simplifying infrastructure and reducing operational management overhead.  
- **Delivery**:  
  - **App Distribution**: Deployed via the Apple App Store for coaches, parents, and sports organizations.  
  - **Backend Services**: Hosted on the Firebase platform, with optional emulator support for local testing and staging environments.

#### Why Firebase?

- Seamless authentication for end-users using email/password or 3rd-party identity providers.  
- Real-time database + Firestore rules for secure, role-based data access.  
- Scalable data storage with automatic backups and minimal operational overhead.

### Security & Privacy Model

- **Facial Blurring by Default**: Protects child identities; only designated users with explicit “unblur” permissions can see or export unblurred faces.  
- **Granular Permission Controls**: Parents or authorized coaches decide who can view or export certain players’ faces in highlight reels.  
- **Zero-Trust Approach**: The system ensures no one (including staff) can see a child’s face unless specifically granted.  
- **Encrypted Connections**: All data-in-transit uses TLS/SSL; at-rest encryption is handled by Firebase Cloud Storage.  

### Scalability & Performance

- **Horizontal Scaling**: As usage grows, Firestore and Firebase Functions handle added load automatically.  
- **AI Pipeline Offloading**: Resource-heavy tasks (facial recognition, transcript generation, event detection) can be offloaded to Cloud Functions or specialized cloud-based ML services.  
- **Resource Optimization**: Swift concurrency ensures the app’s front-end remains responsive through parallelized tasks, even on older iOS devices.

### System Architecture

```mermaid
flowchart LR
    A([iOS App<br>(SwiftUI, Swift 6)]) <--> B([Firebase Auth/Firestore/Storage/Functions])
    B --> C([AI Pipeline<br>(Cloud Fn’s, GPU/ML Tools)])
```

```plaintext
+----------------------+       +---------------------------+
|         iOS App      |       |  Firebase Auth / Firestore|
|  (SwiftUI, Swift 6)  | <---> |  Storage/ Functions, etc. |
+----------------------+       +------------+--------------+
                                         |
                                         v
                                 +-----------------+
                                 |  AI Pipeline    |
                                 |  (Cloud Fn’s,   |
                                 |   GPU/ML Tools) |
                                 +-----------------+
```

1. **Core iOS App**: Offers a SwiftUI-based UI, sign-in flows, video uploads, immediate playback, and background data sync.
2. **Firebase Backend**:
   - **Auth**: Manages user sessions, sign-in, and sign-up.
   - **Firestore**: Stores user data, team config, and references to video metadata.
   - **Storage**: Securely keeps original and processed video files.
   - **Functions**: Runs serverless code for tasks like generating highlights, extracting transcripts, or applying face blurring.
3. **AI Pipeline**: Deployed within Firebase Functions or external ML services, orchestrating face recognition, action detection, and transcript generation.

### Key Integrations & Dependencies

- **Firestore / Storage Rules**: Fine-grained security layer controlling read/write operations, ensuring only authorized viewers see unblurred faces.  
- **Swift Concurrency**: Achieves responsive UI for real-time tasks, ensuring data is processed off the main thread.  
- **Third-Party**: Potentially integrates with external libraries for advanced face recognition or compression algorithms.

### Roadmap Considerations

1. **Multi-Platform Expansion**  
   - Explore Android or web-based clients, reusing existing AI pipeline and Firebase backend.  
2. **Advanced Role-Based Access**  
   - Configurable roles (coach, recruiter, athletic director) with granular privileges.  
3. **Expanded Analytics**  
   - Deeper usage analytics to understand which features (highlight reels, transcripts) are most utilized.  
4. **Edge Cases & Offline**  
   - Queuing uploads when offline or network-limited, auto-resuming once available.

---

## For Engineers

### Repository Structure

The repository follows a mono-repo style to keep all source code and configuration in one place:

```plaintext
.
├─ App/                # iOS SwiftUI App
│  ├─ Main entry (AppDelegate, SceneDelegate, or @main struct)
│  ├─ Feature Modules (Authentication, VideoUpload, Teams, etc.)
│  ├─ Utilities/       # Shared helpers / global errors
│  ├─ Logging/         # UnifiedLogger for structured logs
│  ├─ Localization/    # .lproj folders for translated strings
│  └─ ...
├─ Firebase/
│  ├─ Functions/       # Node/TypeScript or Python code for serverless AI tasks
│  ├─ Config/          # firebase.json, env files, etc.
│  ├─ SecurityRules/   # firestore.rules, storage.rules
│  ├─ Emulators/       # Local emulator configuration
│  ├─ ...
├─ Tests/
│  ├─ AppTests/        # Unit tests for Swift code
│  ├─ IntegrationTests/# Firebase integration tests
│  └─ UITests/         # Automated UI tests
├─ Docs/
│  └─ # Additional specification & user docs
└─ ...
```

### Environment & Configuration

- **Build Configurations**:  
  - **Debug**: Points to local Firebase emulators or a dev environment.  
  - **Staging**: Points to a staging version of Firebase for QA.  
  - **Production**: Points to the live environment.  
- **Firebase .plist Files**:  
  - Keep separate for each environment (`GoogleService-Info-Dev.plist`, `GoogleService-Info-Prod.plist`).  
- **Secrets & Credentials**:  
  - Avoid committing sensitive keys to the repo.  
  - Use GitHub Actions secrets, environment variables, or `dotenv`-style files.

### Local Development & Testing

1. **Clone & Install**  
   - Clone the repo and open `App/AiAiO.xcodeproj` with Xcode 15.2 or higher.  
2. **Emulators**  
   - Install and run `firebase emulators:start` in the `Firebase/Emulators/` folder.  
   - By default, debug builds can point to the local emulator suite for Auth, Firestore, and Storage.  
3. **Unit Testing**  
   - `AppTests/` covers pure Swift logic and concurrency checks.  
   - Run via Xcode’s built-in test runner (⌘U) or use `xcodebuild test`.  
4. **Integration & UI Testing**  
   - `IntegrationTests/` tests real or emulated Firebase interactions.  
   - `UITests/` uses XCTest for sign-in flows, video uploads, and other user journeys.  

### AI Pipeline Overview

- **Facial Recognition & Blurring**  
  - Implemented as Cloud Functions or containers triggered on new video uploads.  
  - On success, the server updates metadata (e.g., bounding boxes, face IDs) in Firestore.  
  - Clients read these to decide which faces to blur or show.  
- **Transcript Generation**  
  - Uses speech-to-text services, triggered **asynchronously** post-upload.  
  - Completed transcripts are stored in Firestore, then displayed to users for quick search or highlight reel generation.  
- **Highlight Detection**  
  - Analyzes events like goals, assists, or unique motion patterns from the video.  
  - A separate function writes highlight metadata to Firestore for easy retrieval.

### Code Organization & Best Practices

- **MVVM and ObservableObjects**  
  - Each feature (Teams, VideoUpload, Authentication) has its own `ViewModel` responsible for bridging view state and data services.  
- **Swift 6 Concurrency**  
  - Use `async/await` to fetch user data, handle Firestore reads/writes, and parse results.  
  - Actors manage shared mutable state to reduce risk of data races.  
- **Logging**  
  - Replace all `print()` statements with `UnifiedLogger`.  
  - Distinguish `.info`, `.warning`, `.error` logs, especially for network or server-related errors.  
- **Error Handling**  
  - A global `GlobalError` enum captures known error cases like `networkFailure`, `authenticationFailed`, or `serverError`.  
  - Keep domain-specific errors local to the relevant feature (e.g., `VideoUploadError` if needed).

### Pull Request & Review Process

1. **Branching**  
   - Create a feature branch from `development`: `feature/sliceN-taskN.description`  
2. **Development**  
   - Commit frequently using the [Git Workflow Guidelines](./.cursor/rules/commit-conventions.mdc).  
   - Write or update tests as you implement features/fixes.  
3. **Create a PR**  
   - Target `development` with a clear description, referencing any related issues.  
   - CI runs lint checks, unit tests, integration tests, and concurrency checks.  
4. **Review & Merge**  
   - Address reviewer comments.  
   - Use **squash & merge** with descriptive commit messages.  
   - Deploy to the relevant environment (staging, production) once merged.

---

**Questions or Suggestions?**  

- Please open an issue or reach out to the maintainers. We welcome contributions and feedback to improve AiAiO’s performance, code quality, and developer experience.

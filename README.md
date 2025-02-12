[![iOS CI](https://github.com/brettdavies/ReelAI/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/brettdavies/ReelAI/actions/workflows/ios-ci.yml)

# ReelAI

## Reimagining TikTok with AI

ReelAI is a secure, AI-enabled video sharing platform built with modern SwiftUI and Firebase technologies. Designed for creators—including parents, coaches, and teachers—ReelAI rethinks short-form video by leveraging artificial intelligence to simplify content creation, enhance privacy, and deliver a personalized experience for both content creators and consumers.

## Overview

ReelAI transforms the way videos are captured, edited, and shared. By automating tedious tasks (such as video editing, metadata generation, and format validations) with AI, ReelAI enables creators to focus on their content while ensuring a privacy-first, zero-trust experience for all users.

Key features include:

- Authentication & Secure Access:
Robust sign-up and sign-in flows with Firebase Auth and zero-trust security rules.

- Team Management:
Create and manage teams (previously known as groups) to control who can view and interact with content.

- Video Upload & Offline Caching:
A SwiftUI interface for video selection/recording with client-side validations and offline caching using SwiftData.

- AI-Enabled Metadata Generation:
Cloud Functions process videos to generate summaries, transcriptions, and perform facial/jersey recognition.

- Robust Logging & Error Handling:
A unified logging system captures events and errors, ensuring high observability and streamlined debugging.

## Technology Stack

- iOS: Swift 6 with SwiftUI on iOS 18 (minimum deployment target iOS 18.2)
- Firebase:
- Authentication, Firestore, Storage, Cloud Functions, and Remote Config
- Local development via the Firebase Emulator Suite
- AI Processing: Cloud Functions (Python 3.12) for video metadata and content analysis
- Cursor IDE: AI-assisted code editing and project management (as an alternative to Xcode)
- SwiftPM: All dependencies are managed via Swift Package Manager (no Node-based packages)

## Repository Structure

The repository is organized as a monorepo:

- App/
  Contains the iOS application built in SwiftUI, organized into feature folders such as:
  - Authentication/ (Views, ViewModels, Services)
  - Teams/ (formerly Groups – Views, ViewModels, Models)
  - VideoUpload/ (Views, ViewModels, Services)
  - Utilities/ (GlobalError, GlobalValidator, ToastManager, etc.)
  - Localization/ (Language-specific .lproj folders)
  - Logging/ (UnifiedLogger, Crashlytics integration)

- Firebase/
  Contains backend code and configurations:
  - Functions/ – Cloud Functions code for video processing and AI metadata
  - Config/ – firebase.json, Firestore indexes, and environment configuration files
  - SecurityRules/ – Firestore and Storage rules (managed via the Firebase CLI)
  - Emulators/ – Local emulator configurations for Auth, Firestore, Storage, and Functions

- Tests/
  Contains Unit, Integration, and UITests

- Docs/
  Project documentation, design documents, and user guides

## Setup Instructions

1. Install Prerequisites:

   - Cursor IDE for AI-assisted editing (or use your preferred IDE)
   - Homebrew
   - Xcode 15.2 (or later) with Swift 6 support

2. Install Command-Line Tools:

   - xcbeautify: brew install xcbeautify
   - swiftformat: brew install swiftformat
   - Firebase CLI: brew install firebase-cli

3. Configure Firebase:

   - Ensure you have a Firebase project set up.
   - In the Firebase/Config folder, verify your firebase.json and other config files.
   - Use the Firebase Emulator Suite for local development:

   ```bash
   firebase emulators:start --project <your_project_id>
   ```

4. Build & Run:

   - Open the project in Xcode (all dependencies are managed via SwiftPM).
   - Use the Sweetpad extension (or build server commands) as described in the documentation to build and run the app.
   - Use the integrated debugging tools in Cursor for a streamlined development experience.

5. Debugging & Logging:

   - All significant events and errors are logged via the UnifiedLogger and surfaced in the console.
   - For toast notifications and error feedback, the app uses a global ToastManager that you can trigger from any view.

## Contributing

- Branch per Task:
Create feature branches (e.g., feature/slice3-team-management) for each task.

- PR Guidelines:
Ensure that all tests pass and follow the coding guidelines provided in the documentation.

## CI/CD:
GitHub Actions handle linting, unit tests, integration tests, and deployment steps.

## Happy coding!

ReelAI is built to empower creators with cutting-edge AI and a privacy-first approach—welcome to the future of video sharing.

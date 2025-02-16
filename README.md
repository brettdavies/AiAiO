# AiAiO – Repository-Wide Overview

[![iOS CI](https://github.com/brettdavies/AiAiO/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/brettdavies/AiAiO/actions/workflows/ios-ci.yml)

Welcome to the **AiAiO** monorepo! This repository powers a secure, AI-enabled video sharing platform built with modern **SwiftUI** and **Firebase** technologies. AiAiO merges intuitive mobile workflows with a flexible cloud infrastructure to accelerate video uploads, AI-driven metadata generation, and secure sharing among teams, parents, and coaches.

---

## Table of Contents

- [AiAiO – Repository-Wide Overview](#aiaio--repository-wide-overview)
  - [Table of Contents](#table-of-contents)
  - [What Is AiAiO?](#what-is-aiaio)
  - [Core Components](#core-components)
  - [Key Features](#key-features)
  - [Repository Structure](#repository-structure)
  - [Getting Started](#getting-started)
  - [Where to Find More Details](#where-to-find-more-details)
  - [Contributing](#contributing)

---

## What Is AiAiO?

AiAiO rethinks short-form video by leveraging AI to simplify content creation and ensure a privacy-centric experience. Originally inspired by the needs of sports coaches, parents, and instructors, it scales across various use cases: from robust video analysis and highlights to secure team-based collaboration and face-blurring for minors.

---

## Core Components

- **iOS App (SwiftUI)**: A modern, Swifty interface for video capture, offline caching, and team-based collaboration.  
- **Firebase Backend**: A suite of services, including Firestore, Storage, Authentication, and Cloud Functions, providing real-time data sync and serverless compute capabilities.  
- **AI Integration**: Specialized Cloud Functions for automated metadata generation (e.g., video summaries, transcripts, and face detection or blurring).  

---

## Key Features

1. **Authentication & Secure Access**  
   - Email/password sign-up, multi-factor flows, and token-based session management via Firebase Auth.  
   - Role-based permissions to control video visibility, face “unblurring,” and team membership.

2. **Video Upload & Processing**  
   - SwiftUI-based upload flows with built-in validations, offline caching, and progress indicators.  
   - Automatic AI tasks (e.g., summarization, frame extraction, transcriptions) triggered on file finalize events in Firebase Storage.

3. **Privacy-First Face Blurring**  
   - Ensures that minors’ faces are blurred by default.  
   - Granular permissions allow parents or owners to selectively “unblur” specific subjects for an authorized audience.

4. **Team Management**  
   - Create, manage, and collaborate within teams (groups).  
   - Assign videos to a team, track ownership, and share curated content with coaches, parents, or staff.

5. **Logging & Observability**  
   - Comprehensive logging from both the iOS client and Cloud Functions.  
   - Error handling and notifications in Firebase console or third-party monitoring solutions.

---

## Repository Structure

Below is a high-level look at the folders in this monorepo:

- **App/**  
  - The SwiftUI iOS application. Handles video capture, uploads, local caching, AI triggers, and user-facing features.  
  - See [App/README.md](App/README.md) for a more detailed overview of app architecture and user flows.

- **Firebase/**  
  - Firebase project configuration, security rules, and Cloud Functions.  
  - Has subfolders like:
    - **Functions/**: Python-based (or Node.js-based) Cloud Functions for serverless video processing.  
    - **Config/**: Environment-specific configs, `.env` files, Firestore indexes, etc.  
    - **SecurityRules/**: Firestore and Storage rules for controlling data access.  
  - See [Firebase/README.md](Firebase/README.md) for more details on how these pieces fit together.

- **Tests/**  
  - Contains unit, integration, and UI tests.  
  - Helps ensure reliability across both iOS and backend components.

- **Docs/**  
  - Houses design documents, project plans, or any additional references.  
  - Ideal for deeper architectural discussions or advanced usage guides.

---

## Getting Started

1. **Install Prerequisites**  
   - Xcode 15.2+ (with Swift 6) for iOS development.  
   - Homebrew or your preferred package manager for tools like `swiftformat`, `xcbeautify`, and the Firebase CLI.  
   - Python 3.12+ (if working on Cloud Functions in Python).

2. **Clone the Repo**  
   - Clone this repository to your local machine and check out the `development` branch or an appropriate feature branch.

3. **Configure Firebase**  
   - Set up your Firebase project in the `Firebase/Config` folder.  
   - Run the local emulator suite (`firebase emulators:start`) for safer testing.

4. **Build & Run**  
   - Open the `App/` project in Xcode, resolve SwiftPM dependencies, and run on a device or simulator.  
   - For Firebase Functions, ensure you install the required Python dependencies (see function-specific `requirements.txt` if you’re using Python).

5. **Emulator Testing**  
   - Use the Firebase local emulator for verifying Firestore rules, upload triggers, and function executions end-to-end.

---

## Where to Find More Details

- **iOS App**  
  - [App/README.md](App/README.md) – Overview of SwiftUI design, user flows, AI-driven face blurring, and offline caching strategies.

- **Firebase**  
  - [Firebase/README.md](Firebase/README.md) – High-level summary of rules, emulator usage, and expansions (e.g., hosting).  

- **Video Summary Function**  
  - [Firebase/functions/video_summary/README.md](Firebase/functions/video_summary/README.md) – Explains how the summarization edge function extracts frames with FFmpeg and calls AI endpoints to generate insights.

- **Project Documentation**  
  - [Docs/](Docs/) – Contains design documents, development guidelines, and any specialized documentation or proposals.

---

## Contributing

1. **Create a Branch**  
   - Follow the [Git Workflow Guidelines](.cursor/rules/git-workflow.mdc) for feature branches and commits.

2. **Make Changes & Test**  
   - Ensure you run all relevant tests before committing.  
   - Use local emulators to validate Firebase changes.

3. **Pull Request & Review**  
   - Open a PR into `development` when your changes are ready.  
   - Reference additional instructions in each component’s README for testing or environment details.

4. **Merge & Deploy**  
   - On successful review and testing, your changes can be squash-merged into `development` and deployed after final validations.

---

Thank you for exploring the **AiAiO** repository! We’re excited you’re here to build a more intelligent, secure, and user-friendly video platform. For questions, issues, or suggestions, feel free to [open an issue](https://github.com/brettdavies/AiAiO/issues) or reach out to the project maintainers. Happy coding!

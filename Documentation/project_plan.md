---
title: "AiAiO Project Plan"
version: "1.1.0"
last_updated: "2025-02-10"
description: "High-level development roadmap for AiAiO, focusing on a secure, AI-enabled video sharing platform for creators."
---

# AiAiO Project Plan

[![iOS CI](https://github.com/brettdavies/ReelAI/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/brettdavies/ReelAI/actions/workflows/ios-ci.yml)

Reimagining TikTok With AI

## Table of Contents

- [AiAiO Project Plan](#aiaio-project-plan)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Vertical Slices (Phases)](#vertical-slices-phases)
  - [Architecture \& Technology](#architecture--technology)
  - [Key Considerations](#key-considerations)
  - [Development \& Branching Workflow](#development--branching-workflow)

---

## Overview

AiAiO is a secure, AI-enabled video sharing app aimed at parents, coaches, and teachers (“creators”) who want to share videos of children in a privacy-first manner. This platform adopts a **zero-trust** model (no open access by default) and automatically generates AI-based metadata (summaries, transcriptions, face/jersey recognition) using **Firebase Cloud Functions**.

**Mono-Repo Structure** (all tasks rely on CLI-based operations rather than manual dashboard actions):

- **`/App`**: Swift 6 + SwiftUI iOS application (MVVM architecture, environment-based config, concurrency checks).
- **`/Firebase`**: Python-based Firebase backend (Cloud Functions in Python 3.12, Security Rules, Emulators, Firestore indexes). Use the **Firebase CLI** for all deployments, rule updates, and configuration changes.

**Core Features**:

1. **Authentication** (secure sign-up/sign-in, zero-trust rules)
2. **Group & Roster Management** (teams, face/number data for AI)
3. **Video Upload & Offline Caching** (max 100MB, SwiftData-based queue)
4. **AI-Enabled Metadata** (face recognition, jersey detection, auto-transcription)
5. **Privacy & Access Control** (whitelist approach with group-based restrictions)
6. **Robust Logging & Error Handling** (using a global `UnifiedLogger`, typed `GlobalError`)

---

## Vertical Slices (Phases)

1. **Slice 1: Foundation & Project Setup**  
   - Project scaffolding, environment-based config, local Firebase Emulators, global logging/error handling, **no** manual Firebase console usage.

2. **Slice 2: Authentication & Secure Access**  
   - SwiftUI sign-up/sign-in with Firebase iOS SDK, Firestore/Storage security rules (via CLI), zero-trust baseline.

3. **Slice 3: Group & Roster Management**  
   - Creating/editing groups (Firestore), storing child info for AI referencing, associated security rules deployed with CLI.

4. **Slice 4: Video Upload & Offline Caching**  
   - SwiftUI UI for video selection (using Swift libraries managed by Xcode package manager only), local caching (SwiftData), size/type validations.

5. **Slice 5: AI-Enabled Metadata Creation**  
   - Cloud Functions triggered on video upload, face recognition, jersey # detection, transcription. All function deployments via Firebase CLI.

6. **Slice 6: Privacy & Access Control**  
   - Refined Firestore/Storage rules, only group members/owners can access relevant data. All rules pushed by Firebase CLI commands.

7. **Slice 7: Testing & QA**  
   - Automated unit, integration, UI tests (Xcode), concurrency checks, SwiftLint. Firebase Emulators used for integration testing.

8. **Slice 8: Deployment & Beta Distribution**  
   - TestFlight or Firebase App Distribution release, user feedback cycle, no manual console modifications.

---

## Architecture & Technology

1. **SwiftUI (iOS 18)** + **Swift 6 Concurrency**.  
2. **Firebase** (Auth, Firestore, Storage, Functions) with **Firebase CLI** for all configuration and deployments.  
3. **Xcode Internal Package Management**: All dependencies (e.g., Firebase iOS SDK) must be added via SwiftPM within Xcode. No `package.json` or Node-based package manager is allowed.  
4. **Zero-Trust** approach enforced by Firestore/Storage security rules.  
5. **AI** services integrated via Cloud Functions or external APIs, always triggered using programmatic or CLI-based workflows.

---

## Key Considerations

- **No Manual Dashboard**: All Firebase rules, function deployments, environment configs, etc. must be handled via the Firebase CLI, ensuring reproducible environments and minimal manual overhead.  
- **Zero-Trust Security**: No data is accessible unless explicitly whitelisted.  
- **Logging**: Use `UnifiedLogger` to capture internal state changes and user actions.  
- **Error Handling**: Map errors to a typed `GlobalError` for consistent messaging.  
- **Offline-First**: SwiftData-based caching for uploads, with an Xcode-managed Swift package for any third-party offline library.  
- **Scalability**: Cloud Functions handle AI tasks, automatically triggered by new Storage uploads.

---

## Development & Branching Workflow

1. **Branch per Task**  
   - Each numbered task in every slice is developed in its own feature branch.  
   - Example: `feature/slice1-task1.1-monorepo`.  
2. **Merge to Development**  
   - After local testing and Firebase Emulator verification, create a pull request into `development`.  
   - Only merge once CI checks pass (lint, tests).  
3. **Periodic Merge to Main**  
   - The `development` branch is periodically merged into `main` when stable.  
   - Tagged releases and versioning occur on `main`.  

Adhering to this workflow ensures a clean, testable progression and minimal reliance on ad-hoc manual changes.

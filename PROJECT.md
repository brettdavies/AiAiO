# AiAiO (ReelAI)

> **Note:** This is a project overview card. For technical documentation and setup instructions, see [README.md](README.md).

## Overview

An AI-enabled privacy-first video sharing platform built for the Gauntlet AI fellowship, reimagining TikTok with AI-first features for creators (parents, coaches, teachers). Implements zero-trust security with Firebase, AI-powered video summarization via Cloud Functions, and offline-capable SwiftUI iOS app with strict Swift 6 concurrency. Delivered production-ready vertical slice in 14 days including CI/CD, comprehensive testing, and automated metadata generation.

## Quick Reference

| Field | Value |
|-------|-------|
| **Status** | Archived (Completed as Gauntlet AI fellowship project) |
| **Deployed URL** | Not publicly deployed (Firebase App Distribution for beta testing) |
| **Build Time** | 14 days (Feb 3-16, 2025) |

## Technical Stack

| Category | Technologies |
|----------|--------------|
| **Languages** | Swift 6, Python 3.12 |
| **Frameworks** | SwiftUI (iOS 18.2+), Firebase iOS SDK |
| **Infrastructure** | Firebase (Auth, Firestore, Storage, Cloud Functions), GitHub Actions |
| **AI/ML** | OpenAI GPT (video summarization), OpenCV (planned face/jersey recognition) |
| **Key Patterns** | MVVM architecture, Zero-trust security, Event-driven (Storage triggers), Offline-first caching |

## Key Achievements

- Built native iOS app (1,823 lines Swift) and serverless backend (128 lines Python) with complete authentication, team management, and video upload features in 14-day time constraint
- Implemented zero-trust security model with Firebase security rules enforcing group-based access control—no data accessible without explicit whitelist
- Automated AI video processing pipeline using Cloud Functions with Storage triggers, generating summaries via OpenAI integration and preparing for face/jersey recognition
- Achieved production-ready code quality with SwiftLint enforcement, GitHub Actions CI/CD, and comprehensive error handling via UnifiedLogger
- Delivered vertical slice covering 6+ user stories from creator flow: authentication, team roster management, offline video caching, cloud upload, AI metadata generation

## Technical Highlights

- **Swift 6 Concurrency & Type Safety:** Strict concurrency checking enabled, all warnings treated as errors, leveraging @MainActor and async/await patterns throughout MVVM architecture for thread-safe UI updates
- **Event-Driven Serverless Architecture:** Cloud Functions (Python 3.12) triggered on Firebase Storage events, processing videos with OpenAI API for summarization with 540s timeout and auto-scaling (0-10 instances)
- **Offline-First Architecture:** SwiftData-based local caching for video uploads with queue management, enabling offline recording and background sync when connectivity restored

## Code Metrics

| Metric | Value |
|--------|-------|
| **Lines of Code** | 1,951 total (1,823 Swift, 128 Python) |
| **Primary Language** | Swift 6 (93%), Python 3.12 (7%) |
| **Test Coverage** | Unit + Integration + UI tests (6 test functions, emulator-based integration) |
| **Key Dependencies** | Firebase iOS SDK, SwiftLint, OpenAI Python SDK, OpenCV, firebase-admin |

---

*For detailed technical documentation, setup instructions, and contribution guidelines, please see [README.md](README.md).*

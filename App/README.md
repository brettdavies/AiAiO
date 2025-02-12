# AiAiO iOS App

## Overview
AiAiO is an AI-powered video sharing platform built with SwiftUI and Firebase. The app follows strict architectural guidelines and best practices for iOS development.

## Requirements
- Xcode 15.2 or later
- iOS 18.2 or later
- Swift 6.0
- Firebase iOS SDK

## Project Structure
```
App/
├── aiaio/                      # Main app directory
│   ├── Authentication/         # Authentication features
│   ├── VideoUpload/           # Video upload features
│   ├── Utilities/             # Shared utilities
│   ├── Localization/          # Localization files
│   ├── Logging/               # Logging system
│   └── Config/                # Environment configuration
```

## Setup
1. Clone the repository
2. Open `aiaio.xcodeproj` in Xcode
3. Build and run the project

## Development Guidelines
- Strict concurrency checking is enabled
- All warnings are treated as errors
- SwiftUI for all UI components
- Comprehensive logging via UnifiedLogger
- Environment-based configuration

## Testing
- Unit tests in aiaioTests
- UI tests in aiaioUITests

## Firebase Configuration
Firebase configuration will be added in subsequent tasks. The app currently supports:
- Development environment with local emulators
- Production environment with live Firebase services 
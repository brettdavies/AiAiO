# AiAiO App – README

Welcome to **AiAiO**, an AI-powered video platform specifically designed for sports coaches, parents of players, and organizations looking to manage and share game footage securely. This README provides a high-level overview of the user experience, features, and workflows. A separate technical README will detail the architecture, code structure, and integrated AI pipeline.

---

## Table of Contents

- [AiAiO App – README](#aiaio-app--readme)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Key Features](#key-features)
  - [User Flows \& Navigation](#user-flows--navigation)
  - [Security \& AI-Driven Privacy](#security--ai-driven-privacy)
  - [Teams \& Collaboration](#teams--collaboration)
  - [Video Management](#video-management)
  - [Authentication \& Accounts](#authentication--accounts)
  - [Future Enhancements](#future-enhancements)

---

## Overview

**AiAiO** is designed to simplify how sports coaches, parents, and various stakeholders upload, manage, and share video content on iOS devices. By blending straightforward user-driven features with an advanced AI pipeline, AiAiO aims to streamline tasks like generating transcripts, detecting key game events, and managing the visibility of player faces:

- **Intuitive Interface**: Built with SwiftUI for fluid interactions and easy navigation.  
- **Fast Authentication**: Quickly sign in or sign up with robust error handling.  
- **Team-Based Collaboration**: Delegate tasks, manage membership, and organize videos under specific teams or groups.  
- **AI-Enhanced Video Processing**: Identify key actions in game footage, generate transcripts for commentary audio, and automatically blur faces for child privacy.

---

## Key Features

1. **Sign In / Sign Up**  
   - Email/password accounts or sign in to an existing account.  
   - Error handling and progress indicators to guide users through authentication.  

2. **Video Upload & Management**  
   - Supports single or bulk video uploads from your iOS photo library.  
   - Duplicate detection to avoid re-uploading the same content.  
   - Progress bars for each upload and robust handling of upload errors.  

3. **AI-Driven Enhancements**  
   - Automatic action-detection for highlight videos (e.g., critical plays or key moments).  
   - Transcription of commentary (if clear audio is detected beyond crowd noise).  
   - Facial recognition to group players and provide adaptive content.  

4. **Privacy-Centric Facial Blurring**  
   - By default, **all faces** are blurred to ensure child privacy.  
   - Parents/unblur rights:  
     - Parents can “unblur” their child’s face, making it visible to themselves or other authorized viewers.  
     - Permissions can be granted to coaches or team members, so they can see a specific child’s face if appropriate.  
   - When videos are exported from the platform, only faces that the exporting user has permission to see remain unblurred.

5. **Team Collaboration**  
   - Create teams, manage membership, and assign ownership of videos.  
   - Secure data flow ensuring only those with permission see unblurred faces or sensitive content.

6. **Responsive UI**  
   - Uses modals, sheets, and SwiftUI’s built-in navigation stacks.  
   - On-screen alerts and toast messages for user feedback without cluttering your view.

---

## User Flows & Navigation

1. **Launch Screen**  
   - Shows the main content if you’re already signed in.  
   - Otherwise, displays the sign-in or sign-up options.  

2. **Sign In / Sign Up Flow**  
   - Basic form with email and password fields.  
   - Immediate feedback on credential errors (e.g., “Invalid email format”).  
   - Short progress bar during sign-up.  

3. **Authenticated Home (Video Grid)**  
   - Lists all your videos in a scrollable, visually engaging grid.  
   - “+” floating button for new video picks.  

4. **Detailed Video View**  
   - Tap a video tile to open it fullscreen and begin playback.  
   - Edit metadata (e.g., renaming, team assignment) or refresh AI data when new highlights are generated.  

5. **Export & Sharing**  
   - When you export a video to share, you can configure who has access to unblurred faces.  
   - Automatic checks ensure compliance with the child-privacy rules you’ve configured.

---

## Security & AI-Driven Privacy

1. **Default Blurring**  
   - The platform automatically blurs all faces to protect child identities. No one sees unblurred faces unless given permission.  

2. **Face Unblur Permissions**  
   - Parents control who sees their child’s face. A parent can specifically grant “view unblurred face” permission to coaches, recruiters, or other parents.  
   - Coaches may request unblur rights for certain players to create highlight reels. Parents can approve or deny these requests.  

3. **Highlight-Video Generation**  
   - The AI pipeline identifies key segments (e.g., assists, goals, strong defensive plays).  
   - Only unblurs relevant faces for which the viewer (or exporting user) has permission.  

4. **Private by Design**  
   - If a viewer lacks permission, they will only see blurred faces—screenshots or exports remain blurred.  

---

## Teams & Collaboration

- **Creating a Team**  
  - Tap the “+” button in the Teams section, provide a name and description.  
  - Assign an owner for accountability.  
- **Editing a Team**  
  - Update team info or membership rolls.  
  - Add coaches, parents, or staff to handle different responsibilities (e.g., video reviewing, editing, or commentary).  
- **Assigning Videos to Teams**  
  - Either at upload or later in the video details screen, assign one or more videos to a team.  
  - Bulk-assignment is supported, so you can quickly attach multiple newly uploaded videos to the correct team.

---

## Video Management

1. **Grid Layout**  
   - Scrollable tile view of your videos for quick scanning and visually distinct identification.  
2. **Video Upload**  
   - Pick one or multiple videos from your device library.  
   - App checks for duplicates to avoid redundancy.  
3. **AI & Metadata**  
   - The system automatically starts scanning for action highlights, transcribing commentary, and detecting faces upon upload.  
   - Over time, updated highlights or transcripts can appear in the video’s detail view.  
4. **Playback & Editing**  
   - Fullscreen playback with standard controls.  
   - Edit metadata (video title, associated team, unblurred faces, etc.) as needed.

---

## Authentication & Accounts

- **Sign In**  
  - Enter email/password; on success, you’re taken straight to the video grid.  
- **Sign Up**  
  - Provide an email and secure password; the app signs you in automatically upon account creation.  
- **Sign Out**  
  - From your profile or team menu, one tap signs you out and returns you to the unauthenticated home.

---

## Future Enhancements

- **Advanced Role Permissions**: Allow team owners to define multiple roles, granting or restricting access to specific project areas (e.g., blur overrides, video editing).  
- **Reinforced Offline Support**: Queue video uploads and commentary transcripts for auto-sync when the device reconnects.  
- **Smarter AI Highlights**: Expand to track advanced statistics like player speed, zone coverage, or frequent strategies.  
- **Higher-Grade Transcription**: Improve commentary transcription by leveraging advanced language models.

---

Thank you for choosing AiAiO – we’re excited to help you securely manage, analyze, and share your sports footage with peace of mind regarding player privacy!

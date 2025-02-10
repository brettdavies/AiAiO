# ReelAI

Reimagining TikTok With AI

# Background

TikTok transformed how we view, share, and edit videos online. Not only did they pioneer short-form video, but they also made content creation more accessible to the masses through CapCut. The algorithm they created made "going viral" easier for even the new creator. You were no longer beholden to followers or subscribers \- good content could reach the masses solely based on its quality.

But TikTok emerged in a pre-AI world. What if we could reimagine the platform with today's AI capabilities from the ground up? Instead of users spending hours editing videos, writing captions, or finding trending sounds, AI could transform raw ideas into engaging content. Rather than manually searching for content, AI could understand exactly what entertains each user. Today, we're rebuilding TikTok from an AI-first perspective, where intelligent agents enhance every aspect of creation and consumption.

# Project Overview

This two-week project challenges you to rebuild and reimagine TikTok with AI, while leveraging modern AI tools and capabilities throughout the development process.

## Week 1: Rapid Development (Due February 7 by 6 PM CST)

Use AI-first development tools (Cursor, Lovable, v0, Replit, or Windsurf) to rapidly build a functioning TikTok clone. This week focuses on practicing how AI can accelerate the development of enterprise-scale applications. Your goal is to create a solid foundation that you can enhance in Week 2\.

## Week 2: AI Innovation (Due February 14 by 6 PM CST)

Transform your clone by integrating AI features that enhance how users create, consume, and interact with content. With a working application as your foundation, you'll explore how AI can revolutionize the social video experience.

# Submission Guidelines

At the end of each week, you’ll need to submit the following to the [GauntletAI LMS](https://app.gauntletai.com/):

1. A link to your project’s **public GitHub repository**.

2. A link to the **brainlift** you used to learn, understand, and enhance the application with AI.

3. A **5-minute walkthrough** showcasing what you’ve built (and, where relevant, how you built it).

4. A link to a **post on X or LinkedIn** showcasing what you’ve built.

5. A link to the **working deployed application**.

# Week 1: Rapid Development (Due February 7 by 6 PM CST)

Your first week focuses on building a streamlined version of TikTok using AI development tools. Choose one user type and build a complete experience for them.

## Choose Your Primary User

1. **Content Creator**: Users who make and share videos  
2. **Content Consumer**: Users who discover and engage with content

## Specify Your Niche

Narrow your focus to a specific type of user within your chosen category:

**Creator Examples**:

* Fitness Coach sharing workout routines  
* Chef demonstrating recipes  
* Educator teaching concepts  
* Musician sharing performances  
* Beauty expert creating tutorials

**Consumer Examples**:

* Fitness enthusiast looking for workouts  
* Home cook seeking new recipes  
* Student learning new topics  
* Music fan discovering new artists  
* Beauty enthusiast learning techniques

## Define User Stories

Create detailed user stories for your specific user. For example:

**Fitness Creator Stories**:

* "As a fitness coach, I want to add exercise timestamps to my workout videos"  
* "As a fitness coach, I want to tag videos with difficulty levels"  
* "As a fitness coach, I want to categorize videos by muscle group"

**Recipe Consumer Stories**:

* "As a home cook, I want to save recipes by cuisine type"  
* "As a home cook, I want to filter videos by cooking time"  
* "As a home cook, I want to create collections of weeknight dinner ideas"

## Build Vertically

Build complete features for your specific user type. Each feature should work end-to-end before moving to the next.

For example, **if you choose Creator**:

✅ Complete video upload → processing → publishing pipeline

❌ Partial implementation of comments, likes, AND sharing

**If you choose Consumer**:

✅ Complete video feed → view → interaction flow

❌ Partial implementation of profile, search, AND notifications

**Remember: A fully functional app for one user type is more valuable than a partial implementation trying to serve both.**

### To pass week 1, you must:

1. Build and deploy a working vertical slice  
   1. Pick either **creator or consumer**  
   2. Pick a **niche** within your choice  
   3. Identify **6 user stories** you are aiming to ship for the niche  
2. Showcase your functionality in your video and code  
   1. Highlight your **path, niche, and user stories in your walkthrough video**  
   2. **Show working functionality that matches the 6 user stories** you picked earlier

# Week 2: AI Innovation (Due February 14 by 6 PM CST)

Your second week focuses on enhancing your vertical slice with AI features that meaningfully improve the user experience.

## Understand Features vs. User Stories

An AI **Feature** is a major capability that solves a user problem. Each feature enables multiple **User Stories** \- specific ways users interact with that feature to achieve their goals.

Choose Your AI Features Select 2 AI features that:

* Address real problems for your chosen user type  
* Integrate naturally with your Week 1 implementation  
* Create significant value for your niche

## Define User Stories 

Create **at least 6 user stories across your chosen features**. For example:

**Creator Example**:

* Feature: SmartEdit  
  * "As a creator, I can say 'remove awkward pause' and AI edits out silence"  
  * "As a creator, I can say 'zoom on product' and AI adds zoom effects"  
  * "As a creator, I can say 'enhance lighting' and AI adjusts dark scenes"  
* Feature: TrendLens  
  * "As a creator, I get AI suggestions for optimal video length"  
  * "As a creator, I receive trending hashtag recommendations"

**Consumer Example**:

* Feature: SmartScan  
  * "As a recipe learner, I can ask 'show sauce-making part' and jump there"  
  * "As a recipe learner, I can search for specific techniques shown"  
  * "As a recipe learner, I can find moments where ingredients are listed"  
* Feature: PersonalLens  
  * "As a recipe learner, I get recommendations based on my skill level"  
  * "As a recipe learner, I see content matched to my learning pace"

## Build Vertically

Build complete features for your specific user type. Each feature should work end-to-end before moving to the next.

### To pass Week 2, you must

1. Implement 2 substantial AI Features  
2. Define at least 6 User Stories across your features  
3. Show working functionality that matches these user stories in your video

# Important Technical Decisions (ITDs)

Our recommended stack includes Firebase Auth, Cloud Storage, Firestore, Generative AI in Firebase, Cloud Functions, Cloud Messaging, and App Hosting—with native deployment using Kotlin for Android or Swift for iOS.

### **1\. Firebase Auth**

* **Purpose:**  
   Provide secure user authentication and account management.  
* **Usage:**  
  * Enable sign-up, login, and session management for both content creators and consumers.  
  * Support social logins (Google, Facebook, etc.) to streamline user onboarding.

### **2\. Firebase Cloud Storage**

* **Purpose:**  
   Store and serve media assets reliably.  
* **Usage:**  
  * Manage video file uploads, thumbnails, and other media.  
  * Integrate with Cloud Functions to process or transform media assets before final storage.

### **3\. Firestore**

* **Purpose:**  
   Serve as the primary NoSQL database for real-time data management.  
* **Usage:**  
  * Store metadata such as video descriptions, timestamps, comments, likes, and user profiles.  
  * Provide real-time synchronization of data between the server and client, ensuring a seamless user experience.

### **4\. Generative AI in Firebase**

* **Purpose:**  
   Integrate advanced AI capabilities directly into the Firebase ecosystem.  
* **Usage:**  
  * Leverage generative AI (via Firebase Cloud Functions and external AI APIs) to automate content enhancements (e.g., auto-captioning, smart editing commands).  
  * Enable new AI-driven features like content recommendations or automated video effects.

### **5\. Cloud Functions Firebase**

* **Purpose:**  
   Implement serverless backend logic.  
* **Usage:**  
  * Handle video processing, trigger AI enhancements, and integrate securely with external APIs.  
  * Offload compute-intensive tasks from the client, ensuring scalability and maintainability.

### **6\. Cloud Messaging**

* **Purpose:**  
   Provide real-time notifications and updates to users.  
* **Usage:**  
  * Send push notifications for new content, comments, likes, or AI-generated suggestions.  
  * Enhance user engagement by keeping them informed about relevant interactions or updates.

### **7\. App Distribution on Firebase**

* **Purpose:**  
   Deploy and host the application reliably.  
* **Usage:**  
  * Use Firebase Hosting for mobile components to ensure fast global content delivery.  
  * Leverage Firebase’s integration capabilities to streamline updates and maintain uptime.

### **8\. OpenShot Video Editing API**

* **Purpose:**  
   Manage video editing using an [open source API hosted on AWS](https://aws.amazon.com/marketplace/pp/prodview-e3twc4peeo7g2?sr=0-1&ref_=beagle&applicationId=AWSMPContessa).  
* **Usage:**  
  * Use OpenShot to edit and process video files programmatically.  
  * Leverage OpenShot’s features—including trimming, transitions, and effects—to automate and customize video production workflows.

### **9\. Native Mobile Development – Kotlin or Swift**

* **Purpose:**  
   Develop a platform-specific mobile application.  
* **Usage:**  
  * **Recommended:** Choose **either Kotlin (for Android)** **or Swift (for iOS)** and focus on that platform to ensure depth and quality of implementation.  
  * **Alternative:** Build a cross-platform app using something like Flutter.  
  * Integrate Firebase SDKs for authentication, data storage, messaging, and more, ensuring a smooth, native experience on your chosen platform.

# Test2Pass (T2P) requirements

### **Brainlift**

You must submit a Brainlift that highlights any SpikyPOVs that guided you in choosing AI features for your video platform.

### **Walkthrough Video**

You must screen share and walkthrough your application in a 5 min video. The video must showcase your AI features functioning and highlight how you went about setting up evaluations for these features on LangSmith/LangFuse.

### **GitHub Repository**

You must submit the repository with the code associated with your project submission.

### **Deployed Application**

You must submit a link to the deployed application, where graders can login and try out your AI features.

### To pass week 1, you must:

1. Build and deploy a working vertical slice  
   1. Pick either **creator or consumer**  
   2. Pick a **niche** within your choice  
   3. Identify **6 user stories** you are aiming to ship for the niche  
2. Showcase your functionality in your video and code  
   1. Highlight your **path, niche, and user stories in your walkthrough video**  
   2. **Show working functionality that matches the 6 user stories** you picked earlier  
3. Build a mobile application natively **using Kotlin or Swift**

# AI Tools and Resources

### **Video Editing Integration**

* [Cloudinary Image and Video Handling](https://cloudinary.com/) \- Cloud-based transformation and compression

* [OpenShot AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-e3twc4peeo7g2) \- Your primary video processing API

* [AWS API Gateway Documentation](https://docs.aws.amazon.com/apigateway/) \- For integrating with OpenShot API

* [AWS SDK Documentation](https://docs.aws.amazon.com/sdk-for-javascript/) \- For handling video uploads and API interactions

### **Mobile Development**

* [Firebase App Distribution](https://firebase.google.com/products/app-distribution) \- Pre-Release your mobile app

* [Firebase documentation](https://firebase.google.com/docs) \- Docs for all features

* [Flutter Documentation](https://docs.flutter.dev/) \- Official Flutter documentation

* [Flutter Video Player](https://pub.dev/packages/video_player) \- Video playback in Flutter

* [Flutter AWS Integration](https://docs.amplify.aws/flutter/start/getting-started/) \- AWS Amplify Flutter library

* [Material Design Components](https://m3.material.io/) \- UI design system for mobile apps

* [Flutter State Management](https://docs.flutter.dev/data-and-backend/state-mgmt/intro) \- Managing app state in Flutter

### **Backend Development**

* [Firebase Authentication](https://firebase.google.com/products/auth) \- Manage user login and signup 

* [Firebase Cloud Functions](https://firebase.google.com/products/functions) \- Serverless architecture

* [Supabase Documentation](https://supabase.com/docs) \- Backend infrastructure

* [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction) \- Flutter integration

* [Edge Functions](https://supabase.com/docs/guides/functions) \- Serverless compute

* [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security) \- Data access control

### **Development Tools**

* [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview) \- Flutter debugging and profiling

* [Postman](https://www.postman.com/) \- API testing and documentation

* [Firebase Test Lab](https://firebase.google.com/docs/test-lab) \- Mobile app testing

The architecture for a mobile video platform requires careful planning. You can draw inspiration from modern video apps like TikTok, Instagram Reels, and YouTube Shorts, while leveraging the provided OpenShot API for video processing capabilities.

# Milestones

| Completion date | Project phase | Description |
| :---- | :---- | :---- |
| Feb 5, 2025 | Application MVP | 2-3 cohesive user stories complete |
| Feb 7, 2025 | TikTok Rebuild Complete | 6 or more cohesive user stories complete |
| Feb 9, 2025 | Week 1 Resubmission | Can resubmit to showcase progress |
| Feb 10, 2025 | AI Objectives Start |  |
| Feb 12, 2025 | Week 2 Check-in |  |
| Feb 14, 2025 | AI Features Complete | 2 large AI features working seamlessly |

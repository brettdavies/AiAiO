---
title: "Slice 3 Implementation Details"
version: "1.1.0"
last_updated: "2025-02-10"
description: "Create, edit, and manage teams in Firestore. Store child face data or jersey numbers for AI referencing."
---

# Slice 3: Team & Roster Management

## Table of Contents

- [Slice 3: Team \& Roster Management](#slice-3-team--roster-management)
  - [Table of Contents](#table-of-contents)
  - [Development Process](#development-process)
  - [Goals of Slice 3](#goals-of-slice-3)
  - [Implementation Steps](#implementation-steps)
    - [Task 3.1 Team UI (Create \& Edit)](#task-31-team-ui-create--edit)
    - [Task 3.2 Firestore Schema for Teams](#task-32-firestore-schema-for-teams)
    - [Task 3.3 Roster Data (Faces, Jersey Numbers)](#task-33-roster-data-faces-jersey-numbers)
    - [Task 3.4 Security Rules (Phase 2)](#task-34-security-rules-phase-2)
    - [Task 3.5 Logging \& Error Handling](#task-35-logging--error-handling)
    - [Task 3.6 Verification / Demo](#task-36-verification--demo)

---

## Development Process

Before starting any task:

1. **Review Required Documentation**
   - [Git Workflow Guidelines](../../.cursor/rules/git_workflow.mdc) - **REQUIRED** for all commits and PRs
   - [Swift Rules](../../.cursor/rules/swift-rules.mdc) - For Swift code
   - [Project Structure](../../.cursor/rules/project-structure.mdc) - For file organization

2. **Git Workflow Summary**
   - Create feature branch: `feature/slice3-task<N>-<description>`
   - Make atomic commits following [commit conventions](../git_workflow.md#commit-process)
   - Create PR with comprehensive description
   - Squash merge to development after review
   - Delete feature branch after merge

3. **Pull Request Requirements**
   - All tests must pass
   - Code must follow style guides
   - Changes must be atomic and focused
   - PR description must be detailed
   - Squash merge is required

---

## Goals of Slice 3

1. **Team Creation & Editing**: SwiftUI screens to create a new team (e.g., "U10 Soccer Team").  
2. **Firestore Schema**: Store team documents with fields for roster members, each containing child info (name, face data, jersey #).  
3. **Security Rules**: Refine zero-trust so only team owners can edit their teams. Others get denied.  
4. **Logging & Error Handling**: Use `UnifiedLogger` and `GlobalError` for team creation, roster updates, or rule violations.

---

## Implementation Steps

### Task 3.1 Team UI (Create & Edit)

**Objective**: Provide SwiftUI views for creators to manage teams.

1. **Step 1**: Branch off `development` → `feature/slice3-task3.1-team-ui`.  
2. **Step 2**: In `/App/Teams/Views`, create `TeamListView.swift` and `TeamDetailView.swift`.  
   - `TeamListView` displays existing teams.  
   - `TeamDetailView` allows editing team name, short description, etc.  
3. **Step 3**: SwiftUI previews with mock data to confirm layout.  
4. **Step 4**: Merge to `development` after CI passes.

**Definition of Done** (Machine-Readable):

- Two SwiftUI views exist for team listing and detail/editing.
- They have functioning previews using mock data.
- Code merges into `development` successfully.

---

### Task 3.2 Firestore Schema for Teams

**Objective**: Define how teams are stored in Firestore (via CLI-based updates only).

1. **Step 1**: `feature/slice3-task3.2-team-schema` branch.  
2. **Step 2**: In `/App/Teams/Models/Team.swift`, define a struct:

   ```swift
   struct Team: Codable, Identifiable {
       var id: String
       var name: String
       var description: String
       // optional: creationDate, ownerUID, etc.
   }
   ```

3. **Step 3**: In `/App/Teams/ViewModels/TeamViewModel.swift`, implement Firestore CRUD using async/await:

   ```swift
   createTeam(_ team: Team) async throws
   fetchTeams() async throws -> [Team]
   ```

4. **Step 4**: Test with local emulator, verifying data is stored in teams collection.
5. **Step 5**: Merge to development.

**Definition of Done** (Machine-Readable):

- A Team model with Codable is defined.
- Firestore CRUD calls for teams are implemented using async/await.
- No manual console creation; only CLI + emulator.

---

### Task 3.3 Roster Data (Faces, Jersey Numbers)

[[REMOVED]]

---

### Task 3.4 Security Rules (Phase 2)

**Objective**: Only team owners can create/edit a team, others are denied.

1. **Step 1**: `feature/slice3-task3.4-rules-phase2` branch.
2. **Step 2**: In `/Firebase/SecurityRules/firestore.rules`, refine

```swift
match /teams/{teamId} {
  allow create: if request.auth != null; // or request.auth.uid is team owner
  allow read: if request.auth != null;
  allow update, delete: if resource.data.ownerUID == request.auth.uid;
  match /members/{memberId} { ... }
}
```

3. **Step 3**: Deploy via `firebase deploy --only firestore:rules --project dev`.
4. **Step 4**: Merge after local emulator test.

**Definition of Done** (Machine-Readable):

- Only the team's ownerUID can update the team doc.
- Rules deployed exclusively via Firebase CLI.
- Verified with local emulator before merging.

---

### Task 3.5 Logging & Error Handling

**Objective**: Extend UnifiedLogger usage for team creation, roster updates, etc.

1. **Step 1**: `feature/slice3-task3.5-team-logging` branch.
2. **Step 2**: Log events like `[Teams] Created new team: {id}`, `[Teams] Added member: {memberId}`.
3. **Step 3**: Convert rule rejections or Firestore errors into `GlobalError` (e.g., `.insufficientPermissions`).
4. **Step 4**: Merge after verifying logs and error mappings.

**Definition of Done** (Machine-Readable):

- Team operations produce logs.
- Firestore-related errors map to typed `GlobalError`.
- Merged to development successfully.

---

### Task 3.6 Verification / Demo

**Objective**: Demonstrate team/roster creation, security, and logs.

1. **Step 1**: `feature/slice3-task3.6-verification` branch.
2. **Step 2**: Using the local emulator, create a team as the signed-in user.
3. **Step 3**: Attempt updates from a different user (should fail).
4. **Step 4**: Confirm logs and error messages are correct.
5. **Step 5**: Merge into development upon success.

**Definition of Done** (Machine-Readable):

- Verified team creation flows, security constraints, logs, and error handling.
- Merged into development with passing CI checks.

Estimated Timeline

- 4-6 Days total. Roster management may take extra time if embedding vs. subcollections is chosen.

Next Steps After Slice 3

- Move on to Slice 4 (Video Upload & Offline Caching) to allow creators to attach videos to teams.
- Ensure team references are used in video metadata.

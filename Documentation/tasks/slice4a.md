# Video Upload Pattern

## 1. Store the Video File in Firebase Storage

- Why: Firebase Storage is optimized for large binary files (images, videos, audio). Firestore is not suitable for storing large blobs directly.
- Approach:
  1. When the user selects a video, generate a unique ID (e.g., a UUID) for it.
  2. Upload the raw video bytes to Storage under a path like videos/{videoID}/{filename}.
  3. Obtain either the storagePath or a downloadURL (via StorageReference.downloadURL).
  4. Keep the upload logic in a dedicated upload service.

Example (in Swift pseudo-code):

    ```swift
    let videoID = UUID().uuidString
    let storageRef = Storage.storage().reference()
        .child("videos/\(videoID)/\(fileName)")

    // Upload data
    storageRef.putData(videoData, metadata: nil) { metadata, error in
        if let error = error {
            // Handle error
            return
        }
        storageRef.downloadURL { url, error in
            if let url = url {
                // Save the url or storagePath in Firestore
            }
        }
    }
    ```

## 2. Store the Metadata in Firestore

A. Current (Innate) Metadata

- Examples:
  - Resolution, duration, file size, frame rate, etc.
  - Usually you know some of this at upload time (e.g., from AVAssetTrack or an AVURLAsset).
- When to Store:
  - If you gather resolution/duration right after the user picks the video, you can store it immediately along with the new Firestore document.
  - Alternatively, you can upload the raw file first, then call AVAsset on the local file to gather resolution/duration before saving to Firestore.

B. Externally Assigned Metadata

- Examples:
  - Team association (exactly one team), user’s text description, tags, AI-labeled content in the future, etc.
- Why Firestore:
  - Firestore is great for storing structured data, listening for real-time updates, and quickly querying fields like teamID.

C. Single Firestore Document per Video

A common pattern is to create a videos collection in Firestore, with each doc representing one video:

    ```js
    videos/{videoID} {
    ownerUID: string,
    teamID: string,
    videoURL: string, // or "storagePath"
    resolution: { width, height },
    duration: number,
    fileSize: number,
    description: string,
    createdAt: timestamp,
    updatedAt: timestamp,
    // ... any other fields
    }
    ```

1. videoURL or storagePath
   - You can store the full download URL (for easy playback) or just the Storage path (less public).
2. teamID
   - References the team doc in teams/{teamID}.
   - Because you require exactly one team, you store that single ID.
3. Resolution/Duration
   - If you read them at upload time, you store them now. If you want to do it later (like after a server-based analysis), you can update the doc.

## 3. Handling Future Metadata

A. AI-based or Additional Fields

- If you add more advanced data (like AI-labeled bounding boxes, transcripts, or user analytics), you can:
  - Store them in the same doc (if not too large).
  - Or use sub-collections (videos/{videoID}/analysis/{docID}).
  - Or store large JSON metadata in Storage and reference it in the doc.

B. Evolving Data

- Firestore docs are easy to update. If you add a new field tomorrow (e.g., “category” or “isPublic”), you just write that field to the doc.
- Because you keep the video in Storage, you never rewrite the entire file—only update metadata in Firestore.

## 4. Summary Flow

1. User Picks Video
   - The user selects or records a video in your iOS app. You optionally gather local metadata (resolution, duration) using AVFoundation.
2. Upload to Storage
   - Generate a videoID and a file path: videos/{videoID}/filename.mov.
   - putData to Storage, get a downloadURL or keep the storagePath.
3. Create Firestore Document
   - In videos/{videoID}, store:
     - ownerUID, teamID, videoURL (or storagePath),
     - resolution, duration, etc.
   - This doc is now your “source of truth” for the video’s metadata.
4. Future Updates
   - If you need more fields (like AI-labeled metadata), update the doc or store sub-collection docs.
   - The user can change the team (i.e., update teamID) or the description, etc.

## 5. Offline Considerations

If you want to support offline uploads, you can:

- Cache the video in local SwiftData (or Core Data) with an “upload pending” status.
- Retry once the network is available.
- Once successful, create the Firestore doc.

This pattern ensures the user can pick or record videos offline, and the app syncs them to Firebase when back online.

## Final Recommendation

- Store the video file in Firebase Storage under videos/{videoID}/....
- Then store all metadata—both current (resolution, length) and future (team association, user descriptions, AI-labeled data)—in a Firestore doc in videos/{videoID}, referencing the Storage path or download URL.

This approach is standard in Firebase apps dealing with large media files and evolving metadata.

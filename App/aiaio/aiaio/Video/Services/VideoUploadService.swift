import Foundation
import FirebaseStorage
import Combine

/// A service class that uploads large videos to Firebase Storage without loading them fully into memory.
@MainActor
final class VideoUploadService: ObservableObject {
    
    /// An async method to upload a video from a local file URL to Firebase Storage.
    /// - Parameters:
    ///   - localFileURL: The file URL pointing to the video on disk.
    ///   - videoID: A unique ID for the video (e.g., UUID).
    ///   - progressHandler: Optional closure that provides upload progress updates.
    /// - Returns: The download URL of the uploaded file.
    /// - Throws: A `GlobalError` if the upload fails.
    func uploadVideo(
        localFileURL: URL,
        videoID: String,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> URL {
        
        UnifiedLogger.info("Starting upload for video \(videoID) from file: \(localFileURL.path)", context: "VideoUploadService")
        
        // Create a storage reference. Adjust your path as needed.
        let storageRef = Storage.storage().reference().child("videos/\(videoID)/original.mov")
        
        // Add optional metadata (e.g. contentType).
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        // Perform the upload in an async context with a continuation.
        return try await withCheckedThrowingContinuation { continuation in
            
            // Use putFile to upload from the local file URL. This automatically chunks the file upload.
            let uploadTask = storageRef.putFile(from: localFileURL, metadata: metadata) { metadata, error in
                if let error = error {
                    UnifiedLogger.error("Upload failed for video \(videoID): \(error.localizedDescription)", context: "VideoUploadService")
                    // Convert or map error to GlobalError
                    continuation.resume(throwing: self.mapFirebaseError(error))
                    return
                }
                
                // Attempt to get the download URL
                storageRef.downloadURL { url, error in
                    if let error = error {
                        UnifiedLogger.error("Failed to get download URL for video \(videoID): \(error.localizedDescription)", context: "VideoUploadService")
                        continuation.resume(throwing: self.mapFirebaseError(error))
                        return
                    }
                    guard let downloadURL = url else {
                        UnifiedLogger.error("No download URL returned for video \(videoID).", context: "VideoUploadService")
                        continuation.resume(throwing: GlobalError.unknown("No download URL returned"))
                        return
                    }
                    
                    UnifiedLogger.info("Successfully uploaded video \(videoID). Download URL: \(downloadURL)", context: "VideoUploadService")
                    continuation.resume(returning: downloadURL)
                }
            }
            
            // Observe progress if needed
            if let progressHandler = progressHandler {
                uploadTask.observe(.progress) { snapshot in
                    let fraction = Double(snapshot.progress?.completedUnitCount ?? 0)
                                 / Double(snapshot.progress?.totalUnitCount ?? 1)
                    progressHandler(fraction)
                }
            }
        }
    }
    
    // MARK: - Error Mapping
    
    /// Converts a Firebase error to a `GlobalError`.
    private func mapFirebaseError(_ error: Error) -> GlobalError {
        let nsError = error as NSError
        // Basic mapping
        if nsError.domain == StorageErrorDomain {
            switch StorageErrorCode(_bridgedNSError: nsError) {
            case .unauthorized:
                return .serverError
            case .unknown, .cancelled:
                return .unknown(error.localizedDescription)
            default:
                return .networkFailure
            }
        }
        return .unknown(error.localizedDescription)
    }
}

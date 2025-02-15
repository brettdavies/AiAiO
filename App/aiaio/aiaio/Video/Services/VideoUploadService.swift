import Foundation
import FirebaseStorage
import FirebaseFirestore
import SwiftUI
import UIKit

@MainActor
final class VideoUploadService: ObservableObject {    
    /// Uploads a video file from a local URL to Firebase Storage.
    /// - Parameters:
    ///   - localFileURL: The URL of the video on disk.
    ///   - videoID: A unique identifier for the video.
    ///   - progressHandler: Optional closure providing progress updates.
    /// - Returns: The download URL for the uploaded video.
    func uploadVideo(
        localFileURL: URL,
        videoID: String,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> URL {
        UnifiedLogger.info("Starting upload for video \(videoID) from file: \(localFileURL.path)", context: "VideoUploadService")
        
        let storageRef = Storage.storage().reference().child("videos/\(videoID)/original.mov")
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        return try await withCheckedThrowingContinuation { continuation in
            let uploadTask = storageRef.putFile(from: localFileURL, metadata: metadata) { _, error in
                if let error = error {
                    UnifiedLogger.error("Upload failed for video \(videoID): \(error.localizedDescription)", context: "VideoUploadService")
                    continuation.resume(throwing: self.mapFirebaseError(error))
                    return
                }
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
            if let progressHandler = progressHandler {
                uploadTask.observe(.progress) { snapshot in
                    let fraction = Double(snapshot.progress?.completedUnitCount ?? 0)
                                 / Double(snapshot.progress?.totalUnitCount ?? 1)
                    progressHandler(fraction)
                }
            }
        }
    }
    
    /// Uploads a thumbnail image to Firebase Storage.
    /// - Parameters:
    ///   - thumbnail: The thumbnail image as a UIImage (obtained via SwiftUI if possible).
    ///   - videoID: The unique video identifier.
    /// - Returns: The download URL for the uploaded thumbnail.
    func uploadThumbnail(
        thumbnail: UIImage,
        videoID: String
    ) async throws -> URL {
        UnifiedLogger.info("Starting upload for thumbnail of video \(videoID)", context: "VideoUploadService")
        
        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) else {
            throw GlobalError.encodingError
        }
        
        let storageRef = Storage.storage().reference().child("videos/\(videoID)/thumbnail.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        return try await withCheckedThrowingContinuation { continuation in
            storageRef.putData(thumbnailData, metadata: metadata) { _, error in
                if let error = error {
                    UnifiedLogger.error("Thumbnail upload failed for video \(videoID): \(error.localizedDescription)", context: "VideoUploadService")
                    continuation.resume(throwing: self.mapFirebaseError(error))
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        UnifiedLogger.error("Failed to get download URL for thumbnail of video \(videoID): \(error.localizedDescription)", context: "VideoUploadService")
                        continuation.resume(throwing: self.mapFirebaseError(error))
                        return
                    }
                    guard let downloadURL = url else {
                        UnifiedLogger.error("No download URL returned for thumbnail of video \(videoID).", context: "VideoUploadService")
                        continuation.resume(throwing: GlobalError.unknown("No download URL returned for thumbnail"))
                        return
                    }
                    UnifiedLogger.info("Successfully uploaded thumbnail for video \(videoID). Download URL: \(downloadURL)", context: "VideoUploadService")
                    continuation.resume(returning: downloadURL)
                }
            }
        }
    }
    
    /// Finalizes the upload process by uploading both video and thumbnail,
    /// and then creating/updating the Firestore document with the corresponding URLs.
    /// - Parameters:
    ///   - videoID: The unique identifier for the video.
    ///   - localFileURL: The local file URL of the video.
    ///   - thumbnail: The thumbnail image as a UIImage.
    ///   - teamID: The team identifier associated with the video.
    ///   - date: The creation date of the video.
    ///   - ownerUID: The UID of the authenticated user.
    func finalizeUpload(
        videoID: String,
        localFileURL: URL,
        thumbnail: UIImage,
        teamID: String,
        date: Date,
        ownerUID: String
    ) async throws {
        // Upload video and thumbnail in parallel if desired, or sequentially.
        let videoDownloadURL = try await uploadVideo(localFileURL: localFileURL, videoID: videoID)
        let thumbnailDownloadURL = try await uploadThumbnail(thumbnail: thumbnail, videoID: videoID)
        
        // Create or update the Firestore document with both URLs.
        let docRef = Firestore.firestore().collection("videos").document(videoID)
        let data: [String: Any] = [
            "ownerUID": ownerUID,
            "teamID": teamID,
            "videoURL": videoDownloadURL.absoluteString,
            "thumbnailURL": thumbnailDownloadURL.absoluteString,
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]
        try await docRef.setData(data)
        
        UnifiedLogger.info("Finalized upload for video \(videoID) with both videoURL and thumbnailURL.", context: "VideoUploadService")
    }
    
    // MARK: - Error Mapping
    
    /// Maps a Firebase Storage error to a GlobalError.
    private func mapFirebaseError(_ error: Error) -> GlobalError {
        let nsError = error as NSError
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

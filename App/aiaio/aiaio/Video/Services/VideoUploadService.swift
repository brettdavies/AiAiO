// VideoUploadService.swift

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
    ///   - docID: The Firestore document ID (matching the in-app video ID).
    ///   - progressHandler: Optional closure providing progress updates.
    /// - Returns: The download URL for the uploaded video.
    func uploadVideo(
        localFileURL: URL,
        docID: String,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> URL {
        UnifiedLogger.info("Starting upload for video docID=\(docID) from file: \(localFileURL.path)", context: "VideoUploadService")
        
        let storageRef = Storage.storage().reference().child("videos/\(docID)/original.mov")
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        return try await withCheckedThrowingContinuation { continuation in
            let uploadTask = storageRef.putFile(from: localFileURL, metadata: metadata) { _, error in
                if let error = error {
                    UnifiedLogger.error("Upload failed for docID=\(docID): \(error.localizedDescription)", context: "VideoUploadService")
                    continuation.resume(throwing: self.mapFirebaseError(error))
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        UnifiedLogger.error("Failed to get download URL for docID=\(docID): \(error.localizedDescription)", context: "VideoUploadService")
                        continuation.resume(throwing: self.mapFirebaseError(error))
                        return
                    }
                    guard let downloadURL = url else {
                        UnifiedLogger.error("No download URL returned for docID=\(docID).", context: "VideoUploadService")
                        continuation.resume(throwing: GlobalError.unknown("No download URL returned"))
                        return
                    }
                    UnifiedLogger.info("Successfully uploaded video docID=\(docID). Download URL: \(downloadURL)", context: "VideoUploadService")
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
    ///   - thumbnail: The thumbnail image as a UIImage.
    ///   - docID: The Firestore document ID (matching the in-app video ID).
    /// - Returns: The download URL for the uploaded thumbnail.
    func uploadThumbnail(
        thumbnail: UIImage,
        docID: String
    ) async throws -> URL {
        UnifiedLogger.info("Starting upload for thumbnail of docID=\(docID)", context: "VideoUploadService")
        
        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) else {
            throw GlobalError.encodingError
        }
        
        let storageRef = Storage.storage().reference().child("videos/\(docID)/thumbnail.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        return try await withCheckedThrowingContinuation { continuation in
            storageRef.putData(thumbnailData, metadata: metadata) { _, error in
                if let error = error {
                    UnifiedLogger.error("Thumbnail upload failed for docID=\(docID): \(error.localizedDescription)", context: "VideoUploadService")
                    continuation.resume(throwing: self.mapFirebaseError(error))
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        UnifiedLogger.error("Failed to get download URL for thumbnail of docID=\(docID): \(error.localizedDescription)", context: "VideoUploadService")
                        continuation.resume(throwing: self.mapFirebaseError(error))
                        return
                    }
                    guard let downloadURL = url else {
                        UnifiedLogger.error("No download URL returned for thumbnail of docID=\(docID).", context: "VideoUploadService")
                        continuation.resume(throwing: GlobalError.unknown("No download URL returned for thumbnail"))
                        return
                    }
                    UnifiedLogger.info("Successfully uploaded thumbnail for docID=\(docID). Download URL: \(downloadURL)", context: "VideoUploadService")
                    continuation.resume(returning: downloadURL)
                }
            }
        }
    }
    
    /// Finalizes the upload process by uploading both video and thumbnail,
    /// and then creating/updating the Firestore document with the corresponding URLs.
    /// IMPORTANT: `docID` is the same Firestore document ID used in-app, ensuring consistency.
    /// - Parameters:
    ///   - docID: The Firestore document ID for this video (matches `VideoItem.id`).
    ///   - localFileURL: The local file URL of the video.
    ///   - thumbnail: The thumbnail image.
    ///   - teamID: The team identifier associated with the video.
    ///   - date: The creation date of the video.
    ///   - ownerUID: The UID of the authenticated user.
    func finalizeUpload(
        docID: String,
        localFileURL: URL,
        thumbnail: UIImage,
        teamID: String,
        date: Date,
        ownerUID: String
    ) async throws {
        UnifiedLogger.info("finalizeUpload for docID=\(docID)", context: "VideoUploadService")
        
        let videoURL = try await uploadVideo(localFileURL: localFileURL, docID: docID)
        let thumbnailURL = try await uploadThumbnail(thumbnail: thumbnail, docID: docID)
        
        let docRef = Firestore.firestore().collection("videos").document(docID)
        let data: [String: Any] = [
            "ownerUID": ownerUID,
            "teamID": teamID,
            "videoURL": videoURL.absoluteString,
            "thumbnailURL": thumbnailURL.absoluteString,
            "createdAt": Timestamp(date: date),
            "updatedAt": Timestamp(date: Date())
        ]
        
        // Use merge: true if you prefer to upsert or preserve existing fields.
        try await docRef.setData(data, merge: true)
        
        UnifiedLogger.info("Finalized upload for docID=\(docID) with both videoURL and thumbnailURL.", context: "VideoUploadService")
    }
    
    // MARK: - Error Mapping
    
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

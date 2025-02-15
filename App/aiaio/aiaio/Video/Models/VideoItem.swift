import SwiftUI
import PhotosUI
import AVKit
import FirebaseFirestore

// MARK: - VideoItem Model
struct VideoItem: Identifiable {
    let id = UUID()
    let videoURL: URL
    let thumbnail: UIImage
    let date: Date
    var team: Team?
    
    /// For use in SwiftUI views.
    var thumbnailImage: Image {
        Image(uiImage: thumbnail)
    }
}

extension VideoItem {
    /// Asynchronously creates a VideoItem from a Firestore document.
    static func from(_ document: DocumentSnapshot) async throws -> VideoItem {
        guard let data = document.data(),
              let videoURLString = data["videoURL"] as? String,
              let videoURL = URL(string: videoURLString),
              let createdAtTimestamp = data["createdAt"] as? Timestamp,
              let thumbnailURLString = data["thumbnailURL"] as? String,
              let thumbnailURL = URL(string: thumbnailURLString)
        else {
            throw GlobalError.invalidData
        }
        
        let createdAt = createdAtTimestamp.dateValue()
        // Download the thumbnail image data
        let (imageData, _) = try await URLSession.shared.data(from: thumbnailURL)
        guard let thumbnail = UIImage(data: imageData) else {
            throw GlobalError.decodingError
        }
        
        return VideoItem(videoURL: videoURL, thumbnail: thumbnail, date: createdAt, team: nil)
    }
}

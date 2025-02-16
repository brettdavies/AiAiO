// VideoItem.swift

import SwiftUI
import FirebaseFirestore

enum SummaryStatus: String, Codable {
    case pending
    case processing
    case completed
    case error
}

struct VideoItem: Identifiable {
    let id: String
    let videoURL: URL
    let thumbnail: UIImage
    let date: Date
    var team: Team?
    var summaryStatus: SummaryStatus = .pending
    var shortDescription: String?
    var detailedDescription: String?
    
    var thumbnailImage: Image {
        Image(uiImage: thumbnail)
    }
}

extension VideoItem {
    static func from(_ document: DocumentSnapshot) async throws -> VideoItem {
        // Use docID as the local video ID
        let docID = document.documentID

        guard
            let data = document.data(),
            let videoURLString = data["videoURL"] as? String,
            let videoURL = URL(string: videoURLString),
            let createdAtTimestamp = data["createdAt"] as? Timestamp,
            let thumbnailURLString = data["thumbnailURL"] as? String,
            let thumbnailURL = URL(string: thumbnailURLString)
        else {
            throw GlobalError.invalidData
        }
        let createdAt = createdAtTimestamp.dateValue()
        let (imageData, _) = try await URLSession.shared.data(from: thumbnailURL)
        guard let image = UIImage(data: imageData) else {
            throw GlobalError.decodingError
        }
        var item = VideoItem(
            id: docID,
            videoURL: videoURL,
            thumbnail: image,
            date: createdAt,
            team: nil
        )
        if let summaryData = data["summary"] as? [String: Any],
           let statusString = summaryData["status"] as? String,
           let parsedStatus = SummaryStatus(rawValue: statusString) {
            item.summaryStatus = parsedStatus
            if parsedStatus == .completed {
                item.shortDescription = summaryData["shortDescription"] as? String
                item.detailedDescription = summaryData["detailedDescription"] as? String
            }
        }
        return item
    }
}

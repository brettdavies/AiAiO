import SwiftUI
import PhotosUI
import AVKit

/// Defines the sort order (ascending or descending by date).
enum VideoSortOrder {
    case ascending
    case descending
}

/// Main view model for handling videos (duplicates, filtering, sorting, etc.).
@MainActor
class VideoViewModel: ObservableObject {
    /// All known video items (both newly added and previously loaded).
    @Published var videoItems: [VideoItem] = []
    
    /// The set of teams used to filter videos (if empty, show all).
    @Published var selectedFilterTeams: Set<Team> = []
    
    /// The current sort order for videos (ascending or descending by date).
    @Published var sortOrder: VideoSortOrder = .ascending
    
    /// Used to detect duplicates based on the raw video data hash.
    private var uploadedVideoHashes: Set<Int> = []
    
    /// Returns the videos that pass the current team filter and are sorted by date.
    var displayedVideos: [VideoItem] {
        let filtered = videoItems.filter { video in
            // If no teams are selected, show all. Otherwise only show if video.team is in selectedFilterTeams.
            selectedFilterTeams.isEmpty
            || (video.team != nil && selectedFilterTeams.contains(video.team!))
        }
        return filtered.sorted { lhs, rhs in
            switch sortOrder {
            case .ascending: return lhs.date < rhs.date
            case .descending: return lhs.date > rhs.date
            }
        }
    }
    
    /// Processes newly selected items from the PhotosPicker, generating thumbnails and skipping duplicates.
    /// - Returns: A tuple: (the newly added videos, the number of duplicates skipped).
    func handleNewSelections(_ items: [PhotosPickerItem]) async -> (newVideos: [VideoItem], duplicates: Int) {
        var newlyAdded: [VideoItem] = []
        var duplicateCount = 0
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let hash = data.hashValue
                if uploadedVideoHashes.contains(hash) {
                    duplicateCount += 1
                    continue
                }
                uploadedVideoHashes.insert(hash)
                
                // Write the data to a temporary file.
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("\(UUID().uuidString).mov")
                try? data.write(to: tempURL)
                
                // Generate a thumbnail image asynchronously.
                let thumbnailImage = await generateThumbnail(url: tempURL)
                
                // Use a random date for demonstration (for sorting).
                let randomDate = Date().addingTimeInterval(Double.random(in: -100_000...100_000))
                
                let newVideo = VideoItem(
                    videoURL: tempURL,
                    thumbnail: thumbnailImage,
                    date: randomDate,
                    team: nil
                )
                newlyAdded.append(newVideo)
            }
        }
        
        return (newlyAdded, duplicateCount)
    }
    
    /// Finalizes newly assigned videos after the user picks a team for each.
    func finalizeNewVideos(_ videos: [VideoItem]) {
        videoItems.append(contentsOf: videos)
    }
    
    /// Generates a thumbnail from a given video URL.
    private func generateThumbnail(url: URL) async -> Image {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        return await withCheckedContinuation { continuation in
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, result, _ in
                if let cgImage = cgImage, result == .succeeded {
                    continuation.resume(returning: Image(uiImage: UIImage(cgImage: cgImage)))
                } else {
                    continuation.resume(returning: Image(systemName: "video"))
                }
            }
        }
    }
}

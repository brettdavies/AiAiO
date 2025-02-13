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
    
    /// Used to detect duplicates via partial hashing of the video data.
    private var processedPartialHashes: Set<Int> = []
    
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
    
    /// Processes newly selected items from the PhotosPicker, skipping duplicates by partial hashing.
    /// - Returns: (newlyAdded, duplicates)
    ///   - newlyAdded: The new videos that were not duplicates.
    ///   - duplicates: The number of duplicates skipped.
    func handleNewSelections(_ items: [PhotosPickerItem]) async -> (newlyAdded: [VideoItem], duplicates: Int) {
        var newlyAdded: [VideoItem] = []
        var duplicateCount = 0
        
        for item in items {
            // Attempt to load the raw video data
            if let data = try? await item.loadTransferable(type: Data.self) {
                // Compute a partial hash to detect duplicates in the same session
                let partialHashValue = partialHash(of: data)
                
                if processedPartialHashes.contains(partialHashValue) {
                    duplicateCount += 1
                    continue
                }
                processedPartialHashes.insert(partialHashValue)
                
                // Write data to a temp file
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("\(UUID().uuidString).mov")
                try? data.write(to: tempURL)
                
                // Generate a thumbnail
                let thumbnailImage = await generateThumbnail(url: tempURL)
                
                // For demonstration, random date for sorting
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
    
    /// Computes a lightweight, partial hash of up to the first 64 KB of data
    /// to detect duplicates in the same session without big memory usage.
    private func partialHash(of data: Data, limit: Int = 64_000) -> Int {
        let chunkSize = min(data.count, limit)
        return data.prefix(chunkSize).hashValue
    }
    
}

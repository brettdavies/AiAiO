import SwiftUI
import PhotosUI
import AVKit
import FirebaseFirestore
import Combine

/// Defines the sort order (ascending or descending by date).
enum VideoSortOrder {
    case ascending
    case descending
}

/// Main view model for handling videos (duplicates, filtering, sorting, etc.).
@MainActor
final class VideoViewModel: ObservableObject {
    // MARK: - Published Properties

    /// All known video items (both newly added and previously loaded).
    @Published var videoItems: [VideoItem] = []
    
    /// The set of teams used to filter videos (if empty, show all).
    @Published var selectedFilterTeams: Set<Team> = []
    
    /// The current sort order for videos (ascending or descending by date).
    @Published var sortOrder: VideoSortOrder = .ascending
    
    /// An error state to display user-friendly messages.
    @Published var error: GlobalError?

    // MARK: - Private Properties

    /// Used to detect duplicates via partial hashing of the video data.
    private var processedPartialHashes: Set<Int> = []
    
    /// Combine cancellables for managing subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// Service for handling video uploads.
    private let uploadService: VideoUploadService

    /// Reference to the shared authentication manager.
    private let sessionManager: SessionManager
    
    /// Firestore database reference.
    private let db = Firestore.firestore()

    // MARK: - Computed Properties

    /// Returns the videos that pass the current team filter and are sorted by date.
    var displayedVideos: [VideoItem] {
        let filtered = videoItems.filter { video in
            selectedFilterTeams.isEmpty ||
            (video.team != nil && selectedFilterTeams.contains(video.team!))
        }
        return filtered.sorted { lhs, rhs in
            switch sortOrder {
            case .ascending:  return lhs.date < rhs.date
            case .descending: return lhs.date > rhs.date
            }
        }
    }

    // MARK: - Initialization

    /// Initializes the VideoViewModel with automatic updates based on the current user.
    /// - Parameters:
    ///   - sessionManager: The shared SessionManager managing authentication state.
    ///   - uploadService: The service handling video uploads.
    init(sessionManager: SessionManager, uploadService: VideoUploadService = VideoUploadService()) {
        self.sessionManager = sessionManager
        self.uploadService = uploadService

        // Automatically fetch videos whenever the authenticated user changes.
        sessionManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if user != nil {
                    Task { await self?.fetchVideos() }
                } else {
                    self?.videoItems = []
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Video Fetching

    /// Fetches videos from Firestore for the current authenticated user.
    func fetchVideos() async {
        guard let uid = sessionManager.currentUser?.uid else {
            self.videoItems = []
            return
        }
        do {
            let query = db.collection("videos").whereField("ownerUID", isEqualTo: uid)
            let snapshot = try await query.getDocuments()
            
            // Use a task group to asynchronously convert each document
            let fetchedVideos = try await withThrowingTaskGroup(of: VideoItem.self) { group -> [VideoItem] in
                for document in snapshot.documents {
                    group.addTask {
                        return try await VideoItem.from(document)
                    }
                }
                var videos: [VideoItem] = []
                for try await video in group {
                    videos.append(video)
                }
                return videos
            }
            
            self.videoItems = fetchedVideos
        } catch {
            UnifiedLogger.error("Failed to fetch videos: \(error.localizedDescription)", context: "VideoViewModel")
            self.error = GlobalError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Handling New Video Selections

    /// Processes newly selected video items from the PhotosPicker, filtering out duplicates.
    /// - Parameter items: The newly selected PhotosPicker items.
    /// - Returns: A tuple containing the new videos and the count of duplicates skipped.
    func handleNewSelections(_ items: [PhotosPickerItem]) async -> (newlyAdded: [VideoItem], duplicates: Int) {
        var newlyAdded: [VideoItem] = []
        var duplicateCount = 0

        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let partialHashValue = partialHash(of: data)
                if processedPartialHashes.contains(partialHashValue) {
                    duplicateCount += 1
                    continue
                }
                processedPartialHashes.insert(partialHashValue)
                
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("\(UUID().uuidString).mov")
                try? data.write(to: tempURL)
                
                // Assume generateThumbnail now produces a UIImage.
                let thumbnailImage = await generateThumbnail(url: tempURL)
                // For simplicity, assign a random date; in production, use actual metadata.
                let randomDate = Date().addingTimeInterval(Double.random(in: -100_000...100_000))
                
                let newVideo = VideoItem(videoURL: tempURL, thumbnail: thumbnailImage, date: randomDate, team: nil)
                newlyAdded.append(newVideo)
            }
        }
        return (newlyAdded, duplicateCount)
    }
    
    // MARK: - Finalizing New Videos

    /// Finalizes newly selected videos by uploading them to Storage and creating Firestore documents.
    /// - Parameter videos: The videos that have been assigned teams.
    func finalizeNewVideos(_ videos: [VideoItem]) {
        // Append locally to update the UI immediately.
        videoItems.append(contentsOf: videos)
        
        Task {
            for video in videos {
                let videoID = UUID().uuidString
                do {
                    try await uploadService.finalizeUpload(
                        videoID: videoID,
                        localFileURL: video.videoURL,
                        thumbnail: video.thumbnail,
                        teamID: video.team?.id ?? "",
                        date: video.date,
                        ownerUID: sessionManager.currentUser?.uid ?? ""
                    )
                    UnifiedLogger.info("Video \(videoID) successfully finalized in Firestore.", context: "VideoViewModel")
                } catch {
                    UnifiedLogger.error("Failed to finalize video \(videoID): \(error.localizedDescription)", context: "VideoViewModel")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Computes a lightweight partial hash of data to detect duplicates.
    private func partialHash(of data: Data, limit: Int = 64_000) -> Int {
        let chunkSize = min(data.count, limit)
        return data.prefix(chunkSize).hashValue
    }
    
    /// Generates a thumbnail image for a given video URL.
    /// - Parameter url: The URL of the video file.
    /// - Returns: A UIImage thumbnail.
    private func generateThumbnail(url: URL) async -> UIImage {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        return await withCheckedContinuation { continuation in
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, result, _ in
                if let cgImage = cgImage, result == .succeeded {
                    continuation.resume(returning: UIImage(cgImage: cgImage))
                } else {
                    // Fallback thumbnail image.
                    continuation.resume(returning: UIImage(systemName: "video")!)
                }
            }
        }
    }
}

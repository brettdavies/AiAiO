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

    // init(uploadService: VideoUploadService = VideoUploadService()) {
    //     self.uploadService = uploadService
    // }

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
            let fetchedVideos: [VideoItem] = snapshot.documents.compactMap { document in
                try? VideoItem.from(document)
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
                    let downloadURL = try await uploadService.uploadVideo(
                        localFileURL: video.videoURL,
                        videoID: videoID
                    )
                    UnifiedLogger.info("Video \(videoID) successfully uploaded to Firebase Storage.", context: "VideoViewModel")
                    
                    try await createVideoDoc(
                        videoID: videoID,
                        downloadURL: downloadURL,
                        teamID: video.team?.id ?? "",
                        date: video.date,
                        ownerUID: sessionManager.currentUser?.uid ?? ""
                    )
                    UnifiedLogger.info("Video \(videoID) successfully created in Firestore.", context: "VideoViewModel")
                } catch {
                    UnifiedLogger.error("Failed to finalize video \(videoID): \(error.localizedDescription)", context: "VideoViewModel")
                }
            }
        }
    }

    /// Creates the Firestore doc for an uploaded video.
    private func createVideoDoc(
        videoID: String,
        downloadURL: URL,
        teamID: String,
        date: Date,
        ownerUID: String
    ) async throws {
        let docRef = db.collection("videos").document(videoID)
        let data: [String: Any] = [
            "ownerUID": ownerUID,
            "teamID": teamID,
            "videoURL": downloadURL.absoluteString,
            "createdAt": Timestamp(date: date),
            "updatedAt": Timestamp(date: Date())
        ]
        try await docRef.setData(data)
    }

    // MARK: - Thumbnail Generation

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
    
    // MARK: - Duplicate Detection

    /// Computes a lightweight, partial hash of up to the first 64 KB of data
    /// to detect duplicates in the same session without big memory usage.
    private func partialHash(of data: Data, limit: Int = 64_000) -> Int {
        let chunkSize = min(data.count, limit)
        return data.prefix(chunkSize).hashValue
    }
}

// MARK: - Firestore Conversion for VideoItem

extension VideoItem {
    /// Creates a VideoItem from a Firestore document.
    /// Assumes that the Firestore doc contains at least a videoURL and createdAt timestamp.
    static func from(_ document: DocumentSnapshot) throws -> VideoItem {
        guard let data = document.data(),
              let urlString = data["videoURL"] as? String,
              let videoURL = URL(string: urlString),
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            throw GlobalError.invalidData
        }
        let createdAt = createdAtTimestamp.dateValue()
        // For simplicity, a placeholder thumbnail is used.
        let thumbnail = Image(systemName: "video")
        // Optionally, parse team information if available.
        return VideoItem(videoURL: videoURL, thumbnail: thumbnail, date: createdAt, team: nil)
    }
}

// VideoViewModel.swift

import SwiftUI
import PhotosUI
import AVKit
import FirebaseFirestore
import Combine

enum VideoSortOrder {
    case ascending
    case descending
}

@MainActor
final class VideoViewModel: ObservableObject {
    @Published var videoItems: [VideoItem] = []
    @Published var selectedFilterTeams: Set<Team> = []
    @Published var sortOrder: VideoSortOrder = .ascending
    @Published var error: GlobalError?
    
    private var processedPartialHashes: Set<Int> = []
    private var cancellables = Set<AnyCancellable>()
    private let uploadService: VideoUploadService
    private let sessionManager: SessionManager
    private let db = Firestore.firestore()
    
    var displayedVideos: [VideoItem] {
        let filtered = videoItems.filter {
            selectedFilterTeams.isEmpty ||
            ($0.team.map { selectedFilterTeams.contains($0) } ?? false)
        }
        let sorted = filtered.sorted {
            switch sortOrder {
            case .ascending:
                return $0.date < $1.date
            case .descending:
                return $0.date > $1.date
            }
        }
        return sorted
    }
    
    init(sessionManager: SessionManager, uploadService: VideoUploadService = VideoUploadService()) {
        UnifiedLogger.info("VideoViewModel init called", context: "VideoViewModel")
        self.sessionManager = sessionManager
        self.uploadService = uploadService
        
        sessionManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                UnifiedLogger.info("SessionManager currentUser changed: \(String(describing: user?.uid))", context: "VideoViewModel")
                if user != nil {
                    Task { await self?.fetchVideos() }
                } else {
                    self?.videoItems = []
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchVideos() async {
        UnifiedLogger.info("fetchVideos called", context: "VideoViewModel")
        guard let uid = sessionManager.currentUser?.uid else {
            UnifiedLogger.info("No currentUser UID, setting videoItems = []", context: "VideoViewModel")
            self.videoItems = []
            return
        }
        do {
            let query = db.collection("videos").whereField("ownerUID", isEqualTo: uid)
            let snapshot = try await query.getDocuments()
            UnifiedLogger.info("fetchVideos got snapshot with \(snapshot.documents.count) docs", context: "VideoViewModel")
            let fetchedVideos = try await withThrowingTaskGroup(of: VideoItem.self) { group -> [VideoItem] in
                for document in snapshot.documents {
                    group.addTask {
                        let vid = try await VideoItem.from(document)
                        UnifiedLogger.info("Fetched videoItem from doc \(document.documentID) -> \(vid.id)", context: "VideoViewModel")
                        return vid
                    }
                }
                var result: [VideoItem] = []
                for try await vid in group {
                    result.append(vid)
                }
                return result
            }
            UnifiedLogger.info("Completed all tasks, setting videoItems count: \(fetchedVideos.count)", context: "VideoViewModel")
            self.videoItems = fetchedVideos
        } catch {
            UnifiedLogger.error("Failed to fetch videos: \(error.localizedDescription)", context: "VideoViewModel")
            self.error = GlobalError.unknown(error.localizedDescription)
        }
    }
    
    /// Creates new VideoItems for each user-selected video. This is the highest upstream
    /// point, so we generate the Firestore doc ID (UUID) here and store it in `VideoItem.id`.
    func handleNewSelections(_ items: [PhotosPickerItem]) async -> (newlyAdded: [VideoItem], duplicates: Int) {
        UnifiedLogger.info("handleNewSelections called with items count: \(items.count)", context: "VideoViewModel")
        var newlyAdded: [VideoItem] = []
        var duplicateCount = 0
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let partialHashValue = partialHash(of: data)
                UnifiedLogger.info("Loaded data from PhotosPickerItem, partialHashValue: \(partialHashValue)", context: "VideoViewModel")
                
                if processedPartialHashes.contains(partialHashValue) {
                    duplicateCount += 1
                    continue
                }
                processedPartialHashes.insert(partialHashValue)
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
                try? data.write(to: tempURL)
                
                let thumbnailImage = await generateThumbnail(url: tempURL)
                let randomDate = Date().addingTimeInterval(Double.random(in: -100_000...100_000))
                
                // Generate the Firestore doc ID here, so it matches in Firestore + local.
                let docID = UUID().uuidString
                let newVideo = VideoItem(
                    id: docID,
                    videoURL: tempURL,
                    thumbnail: thumbnailImage,
                    date: randomDate
                )
                UnifiedLogger.info("Created newVideo with docID: \(docID), partialHash: \(partialHashValue)", context: "VideoViewModel")
                newlyAdded.append(newVideo)
            } else {
                UnifiedLogger.info("Failed to load Data from PhotosPickerItem, skipping", context: "VideoViewModel")
            }
        }
        
        UnifiedLogger.info("handleNewSelections returning newlyAdded count: \(newlyAdded.count), duplicates: \(duplicateCount)", context: "VideoViewModel")
        return (newlyAdded, duplicateCount)
    }
    
    /// Finalize each newly added video by uploading to Storage + Firestore.
    /// The docID was already generated in handleNewSelections, so we re-use `vid.id`.
    func finalizeNewVideos(_ videos: [VideoItem]) {
        UnifiedLogger.info("finalizeNewVideos called with count: \(videos.count)", context: "VideoViewModel")
        videoItems.append(contentsOf: videos)
        
        Task {
            for vid in videos {
                let docID = vid.id  // Reuse the docID from handleNewSelections
                do {
                    UnifiedLogger.info("finalizeUpload for docID=\(docID)", context: "VideoViewModel")
                    try await uploadService.finalizeUpload(
                        docID: docID,
                        localFileURL: vid.videoURL,
                        thumbnail: vid.thumbnail,
                        teamID: vid.team?.id ?? "",
                        date: vid.date,
                        ownerUID: sessionManager.currentUser?.uid ?? ""
                    )
                    UnifiedLogger.info("Video \(docID) finalized in Firestore.", context: "VideoViewModel")
                } catch {
                    UnifiedLogger.error("Failed to finalize video \(docID): \(error.localizedDescription)", context: "VideoViewModel")
                }
            }
        }
    }
    
    func refreshSummary(for video: VideoItem) async -> VideoItem {
        UnifiedLogger.info("refreshSummary called for video: \(video.id)", context: "VideoViewModel")
        guard video.summaryStatus != .completed else {
            UnifiedLogger.info("Video \(video.id) is already completed, returning as is", context: "VideoViewModel")
            return video
        }
        var updated = video
        do {
            // Use the doc ID from the VideoItem itself instead of extracting from the local file path
            let docRef = db.collection("videos").document(video.id)
            let snapshot = try await docRef.getDocument()
            UnifiedLogger.info("refreshSummary got doc snapshot for \(docRef.documentID)", context: "VideoViewModel")
            
            guard
                let data = snapshot.data(),
                let summaryData = data["summary"] as? [String: Any],
                let statusString = summaryData["status"] as? String,
                let parsedStatus = SummaryStatus(rawValue: statusString)
            else {
                UnifiedLogger.info("Doc data or summary fields missing, returning unmodified", context: "VideoViewModel")
                return updated
            }
            
            if parsedStatus == .completed {
                UnifiedLogger.info("Video \(video.id) summary is completed. Setting shortDescription/detailedDescription", context: "VideoViewModel")
                updated.summaryStatus = .completed
                updated.shortDescription = summaryData["shortDescription"] as? String
                updated.detailedDescription = summaryData["detailedDescription"] as? String
            } else {
                UnifiedLogger.info("Video \(video.id) summary status: \(parsedStatus). Not completed yet.", context: "VideoViewModel")
            }
        } catch {
            UnifiedLogger.error("Failed to refresh summary for \(video.id): \(error.localizedDescription)", context: "VideoViewModel")
        }
        return updated
    }
    
    func replaceLocalVideo(_ updated: VideoItem) {
        UnifiedLogger.info("replaceLocalVideo called for updated video: \(updated.id)", context: "VideoViewModel")
        guard let idx = videoItems.firstIndex(where: { $0.id == updated.id }) else {
            UnifiedLogger.info("No matching video found in videoItems for id: \(updated.id)", context: "VideoViewModel")
            return
        }
        videoItems[idx] = updated
        UnifiedLogger.info("Replaced video at index \(idx) with updated summaryStatus: \(updated.summaryStatus)", context: "VideoViewModel")
    }
    
    private func partialHash(of data: Data, limit: Int = 64_000) -> Int {
        let chunkSize = min(data.count, limit)
        return data.prefix(chunkSize).hashValue
    }
    
    private func generateThumbnail(url: URL) async -> UIImage {
        UnifiedLogger.info("generateThumbnail called for \(url.lastPathComponent)", context: "VideoViewModel")
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        return await withCheckedContinuation { continuation in
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, cgImage, _, result, _ in
                if let cgImage = cgImage, result == .succeeded {
                    UnifiedLogger.info("Thumbnail generated successfully", context: "VideoViewModel")
                    continuation.resume(returning: UIImage(cgImage: cgImage))
                } else {
                    UnifiedLogger.info("Thumbnail generation failed, returning placeholder", context: "VideoViewModel")
                    continuation.resume(returning: UIImage(systemName: "video") ?? UIImage())
                }
            }
        }
    }
    
    private func extractVideoID(from url: URL) -> String {
        let id = url.deletingPathExtension().lastPathComponent
        UnifiedLogger.info("extractVideoID for \(url.lastPathComponent) -> \(id)", context: "VideoViewModel")
        return id
    }
}

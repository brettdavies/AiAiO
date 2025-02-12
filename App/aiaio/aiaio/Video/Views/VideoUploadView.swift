import SwiftUI
import PhotosUI
import AVKit

// A model representing a video item
struct VideoItem: Identifiable {
    let id = UUID()
    let videoURL: URL
    let thumbnail: Image
}

struct VideoUploadView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var videoItems: [VideoItem] = MockVideoLibrary.allVideos  // Use mock library for now
    @State private var activeVideo: VideoItem? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                // "Add Video" button using PhotosPicker
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .videos,
                    photoLibrary: .shared()
                ) {
                    Label("Add Video", systemImage: "plus.circle")
                        .font(.headline)
                }
                .onChange(of: selectedItem) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
                            try? data.write(to: tempURL)
                            let thumbnailImage = await generateThumbnail(url: tempURL)
                            let newVideo = VideoItem(videoURL: tempURL, thumbnail: thumbnailImage)
                            videoItems.append(newVideo)
                        }
                    }
                }
                .padding()
                
                // Grid of video thumbnails
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)]) {
                        ForEach(videoItems) { video in
                            Button {
                                activeVideo = video
                            } label: {
                                video.thumbnail
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipped()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Uploaded Videos")
            .sheet(item: $activeVideo) { video in
                VideoPlayerModalView(videoURL: video.videoURL)
            }
        }
    }
    
    // Generate a thumbnail image using AVAssetImageGenerator asynchronously
    func generateThumbnail(url: URL) async -> Image {
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

// A simple mock library with 6 video items (using placeholder URLs and images)
struct MockVideoLibrary {
    static var allVideos: [VideoItem] {
        let placeholder = Image(systemName: "video.fill")
        return (1...6).map { _ in
            VideoItem(videoURL: URL(string: "https://www.example.com/video.mp4")!, thumbnail: placeholder)
        }
    }
}

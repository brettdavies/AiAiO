import SwiftUI
import PhotosUI
import AVKit
// MARK: - VideoItem Model
struct VideoItem: Identifiable {
    let id = UUID()
    let videoURL: URL
    let thumbnail: Image
    let date: Date
    var team: Team?
}

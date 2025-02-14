import SwiftUI
import AVKit

struct VideoPlayerModalView: View {
    let videoURL: URL
    @State private var player: AVPlayer
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var volume: Float = 1.0
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        _player = State(initialValue: AVPlayer(url: videoURL))
    }
    
    var body: some View {
        VStack {
            VideoPlayer(player: player)
                .onAppear {
                    player.play()
                    // Load the duration asynchronously using the new API.
                    if let item = player.currentItem {
                        Task {
                            do {
                                let loadedDuration = try await item.asset.load(.duration)
                                duration = loadedDuration.seconds
                            } catch {
                                // Optionally log or handle the error.
                                duration = 0
                            }
                        }
                    }
                }
                .onDisappear {
                    player.pause()
                }
                .overlay(controlOverlay, alignment: .bottom)
                .background(Color.black)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var controlOverlay: some View {
        VStack {
            Spacer()
            // Volume slider and scrubber
            HStack {
                // Play/Pause Button
                Button(action: {
                    isPlaying.toggle()
                    isPlaying ? player.play() : player.pause()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                // Scrubber
                Slider(value: Binding(
                    get: {
                        currentTime
                    },
                    set: { newValue in
                        currentTime = newValue
                        let targetTime = CMTime(seconds: currentTime, preferredTimescale: 600)
                        player.seek(to: targetTime)
                    }
                ), in: 0...duration)
                .accentColor(.white)
                
                // Volume slider
                Slider(value: Binding(
                    get: { Double(volume) },
                    set: { newValue in
                        volume = Float(newValue)
                        player.volume = volume
                    }
                ), in: 0...1)
                .frame(width: 100)
                .accentColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.5))
        }
    }
}

struct VideoPlayerModalView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerModalView(videoURL: URL(string: "https://www.example.com/video.mp4")!)
    }
}

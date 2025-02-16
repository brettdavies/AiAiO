// VideoPlayerModalView.swift

import SwiftUI
import AVKit
import FirebaseFirestore

struct VideoPlayerModalView: View {
    @State private var player: AVPlayer
    @State private var isPlaying = true
    @State private var currentTime = 0.0
    @State private var duration = 0.0
    @State private var volume: Float = 1.0
    
    @State var videoItem: VideoItem
    @ObservedObject var videoVM: VideoViewModel
    
    @State private var showDescriptionOverlay = true
    
    init(videoItem: VideoItem, videoVM: VideoViewModel) {
        _videoItem = State(initialValue: videoItem)
        _player = State(initialValue: AVPlayer(url: videoItem.videoURL))
        self.videoVM = videoVM
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VideoPlayer(player: player)
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }
            
            if videoItem.summaryStatus == .completed,
               let shortDesc = videoItem.shortDescription,
               showDescriptionOverlay {
                ZStack(alignment: .topTrailing) {
                    Color.black
                        .opacity(0.5)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .padding(.bottom, 150)
                        .ignoresSafeArea(edges: .bottom)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Spacer()
                            Button {
                                showDescriptionOverlay = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .padding([.top, .trailing], 2)
                            }
                        }
                        Text(shortDesc)
                            .font(.footnote)
                            .foregroundColor(Color(white: 0.85))
                            .padding(.horizontal, 12)
                            .padding(.bottom, 8)
                    }
                }
                .transition(.move(edge: .bottom))
                .zIndex(3)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .overlay(controlsOverlay, alignment: .bottom)
    }
    
    private var controlsOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Button {
                    isPlaying.toggle()
                    isPlaying ? player.play() : player.pause()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                Slider(
                    value: Binding(
                        get: { currentTime },
                        set: { newValue in
                            currentTime = newValue
                            let targetTime = CMTime(seconds: currentTime, preferredTimescale: 600)
                            player.seek(to: targetTime)
                        }
                    ),
                    in: 0...duration
                )
                .accentColor(.white)
                Slider(
                    value: Binding(
                        get: { Double(volume) },
                        set: { newValue in
                            volume = Float(newValue)
                            player.volume = volume
                        }
                    ),
                    in: 0...1
                )
                .frame(width: 100)
                .accentColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.5))
        }
    }
}

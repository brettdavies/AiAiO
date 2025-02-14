import SwiftUI
import PhotosUI
import AVKit

struct AuthenticatedContentView: View {
    // Explicitly injected dependency.
    let sessionManager: SessionManager
    
    // The VideoViewModel is now initialized using the provided sessionManager.
    @StateObject private var videoVM: VideoViewModel
    
    // Other dependencies (like TeamViewModel) still come from the environment.
    @EnvironmentObject var teamViewModel: TeamViewModel

    // Local state properties.
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var activeVideo: VideoItem?
    @State private var showingTeamList = false
    @State private var showingFilterSheet = false
    @State private var showingTeamPickerSheet = false
    @State private var showDuplicateAlert = false
    @State private var duplicateCount = 0
    @State private var pendingVideosForTeamAssignment: [VideoItem] = []
    
    // MARK: - Initializer
    
    /// The initializer now explicitly requires a SessionManager,
    /// which is used to create the VideoViewModel.
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        _videoVM = StateObject(wrappedValue: VideoViewModel(sessionManager: sessionManager))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            videoGrid
            floatingAddButton
        }
        .navigationTitle("Videos")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button("View Teams") {
                        showingTeamList = true
                    }
                    Button("Sign Out") {
                        sessionManager.signOut()
                    }
                } label: {
                    Image(systemName: "line.horizontal.3")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingFilterSheet = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        // Present the TeamListView modally.
        .sheet(isPresented: $showingTeamList) {
            TeamListView()
                .environmentObject(teamViewModel)
        }
        // Present the VideoPlayer when a video is selected.
        .sheet(item: $activeVideo) { video in
            VideoPlayerModalView(videoURL: video.videoURL)
        }
        // Present a filter sheet.
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(
                videoVM: videoVM,
                userTeams: teamViewModel.alphabeticalTeams
            ) {
                showingFilterSheet = false
            }
        }
        // Present the team assignment sheet.
        .sheet(isPresented: $showingTeamPickerSheet) {
            TeamPickerSheet(
                teams: teamViewModel.alphabeticalTeams,
                videosNeedingTeam: $pendingVideosForTeamAssignment
            ) {
                videoVM.finalizeNewVideos(pendingVideosForTeamAssignment)
                pendingVideosForTeamAssignment.removeAll()
                showingTeamPickerSheet = false
            }
        }
        // Alert for duplicate video selection.
        .alert(duplicateCount == 1 ? "Duplicate Video" : "Duplicate Videos", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if duplicateCount == 1 {
                Text("You selected 1 video that was already uploaded.")
            } else {
                Text("You selected \(duplicateCount) videos that were already uploaded.")
            }
        }
        // Listen for changes to the PhotosPicker selection.
        .onChange(of: selectedItems) { _, newValue in
            Task {
                let (newlyAdded, duplicates) = await videoVM.handleNewSelections(newValue)
                if duplicates > 0 {
                    duplicateCount = duplicates
                    showDuplicateAlert = true
                }
                selectedItems = []
                if !newlyAdded.isEmpty {
                    pendingVideosForTeamAssignment = newlyAdded
                    showingTeamPickerSheet = true
                }
            }
        }
    }
}

// MARK: - Thin Wrapper

/// A thin wrapper that reads SessionManager (and other dependencies)
/// from the environment and passes them into AuthenticatedContentView.
struct AuthenticatedContentViewWrapper: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var teamViewModel: TeamViewModel
    
    var body: some View {
        AuthenticatedContentView(sessionManager: sessionManager)
            .environmentObject(teamViewModel)
    }
}

extension AuthenticatedContentView {
    private var videoGrid: some View {
        ScrollView {
            if videoVM.displayedVideos.isEmpty {
                Text("No Videos")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 1),
                        GridItem(.flexible(), spacing: 1),
                        GridItem(.flexible(), spacing: 1)
                    ],
                    spacing: 1
                ) {
                    ForEach(videoVM.displayedVideos) { video in
                        Button {
                            activeVideo = video
                        } label: {
                            video.thumbnail
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .clipped()
                        }
                    }
                }
                .padding(.zero)
            }
        }
    }
    
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                PhotosPicker(
                    selection: $selectedItems,
                    matching: .videos,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding()
                }
            }
        }
    }
}

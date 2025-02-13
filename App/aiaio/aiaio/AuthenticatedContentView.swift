import SwiftUI
import PhotosUI
import AVKit

struct AuthenticatedContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var teamViewModel: TeamViewModel
    
    // Our dedicated video VM for duplicates, filtering, sorting, etc.
    @StateObject private var videoVM = VideoViewModel()
    
    // Multiple PhotosPicker selections
    @State private var selectedItems: [PhotosPickerItem] = []
    
    // Modals & alerts
    @State private var activeVideo: VideoItem?
    @State private var showingTeamList = false
    @State private var showingFilterSheet = false
    @State private var showingTeamPickerSheet = false
    
    // Duplicate detection
    @State private var showDuplicateAlert = false
    @State private var duplicateCount = 0
    
    // Newly added videos that need a team
    @State private var pendingVideosForTeamAssignment: [VideoItem] = []
    
    var body: some View {
        ZStack {
            videoGrid
            floatingAddButton
        }
        .navigationTitle("Videos")
        .toolbar {
            // Hamburger menu
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
            // Filter button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingFilterSheet = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        // 1) TeamListView sheet
        .sheet(isPresented: $showingTeamList) {
            TeamListView()
                .environmentObject(teamViewModel)
        }
        // 2) Video player sheet
        .sheet(item: $activeVideo) { video in
            VideoPlayerModalView(videoURL: video.videoURL)
        }
        // 3) Filter sheet
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(videoVM: videoVM, userTeams: teamViewModel.teams)
        }
        // 4) Team picker sheet
        .sheet(isPresented: $showingTeamPickerSheet) {
            TeamPickerSheet(
                teams: teamViewModel.teams,
                videosNeedingTeam: $pendingVideosForTeamAssignment
            ) {
                // Called when user taps Done in TeamPickerSheet
                videoVM.finalizeNewVideos(pendingVideosForTeamAssignment)
                pendingVideosForTeamAssignment.removeAll()
                showingTeamPickerSheet = false
            }
        }
        // Duplicate alert
        .alert("Duplicate Videos", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You selected \(duplicateCount) video(s) that were already uploaded.")
        }
        // PhotosPicker changes
        .onChange(of: selectedItems) { _, newValue in
            Task {
                await handlePhotosPickerChange(newValue)
            }
        }
    }
}

// MARK: - Subviews & Helpers
extension AuthenticatedContentView {
    
    /// The main video grid, showing videoVM.displayedVideos.
    private var videoGrid: some View {
        ScrollView {
            if videoVM.displayedVideos.isEmpty {
                Text("No Videos")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                // Minimal spacing, 3 columns
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
    
    /// A floating button that opens the PhotosPicker to add new videos.
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
    
    /// Handle newly selected videos from the PhotosPicker.
    private func handlePhotosPickerChange(_ items: [PhotosPickerItem]) async {
        let (newlyAdded, duplicates) = await videoVM.handleNewSelections(items)
        if duplicates > 0 {
            duplicateCount = duplicates
            showDuplicateAlert = true
        }
        selectedItems = []
        
        // If user added new videos, prompt for team assignment
        if !newlyAdded.isEmpty {
            pendingVideosForTeamAssignment = newlyAdded
            showingTeamPickerSheet = true
        }
    }
}

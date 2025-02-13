import SwiftUI
import PhotosUI
import AVKit

struct AuthenticatedContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var teamViewModel: TeamViewModel
    
    @StateObject private var videoVM = VideoViewModel()
    
    @State private var selectedItems: [PhotosPickerItem] = []
    
    @State private var activeVideo: VideoItem?
    @State private var showingTeamList = false
    @State private var showingFilterSheet = false
    @State private var showingTeamPickerSheet = false
    
    @State private var showDuplicateAlert = false
    @State private var duplicateCount = 0
    
    @State private var pendingVideosForTeamAssignment: [VideoItem] = []
    
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
        // 1) TeamListView
        .sheet(isPresented: $showingTeamList) {
            TeamListView()
                .environmentObject(teamViewModel)
        }
        // 2) Video Player
        .sheet(item: $activeVideo) { video in
            VideoPlayerModalView(videoURL: video.videoURL)
        }
        // 3) FilterSheet
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(
                videoVM: videoVM,
                userTeams: teamViewModel.alphabeticalTeams
            ) {
                showingFilterSheet = false  // dismiss the sheet
            }
        }
        // 4) TeamPickerSheet
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
        // Duplicate Alert
        .alert(duplicateCount == 1 ? "Duplicate Video" : "Duplicate Videos", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if duplicateCount == 1 {
                Text("You selected 1 video that was already uploaded.")
            } else {
                Text("You selected \(duplicateCount) videos that were already uploaded.")
            }
        }
        // PhotosPicker changes
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

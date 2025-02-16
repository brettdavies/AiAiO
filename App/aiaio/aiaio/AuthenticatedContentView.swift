// AuthenticatedContentView.swift

import SwiftUI
import PhotosUI
import AVKit

struct AuthenticatedContentView: View {
    let sessionManager: SessionManager
    
    @StateObject private var videoVM: VideoViewModel
    @EnvironmentObject var teamViewModel: TeamViewModel
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var activeVideo: VideoItem?
    @State private var showingTeamList = false
    @State private var showingFilterSheet = false
    @State private var showingTeamPickerSheet = false
    @State private var showDuplicateAlert = false
    @State private var duplicateCount = 0
    @State private var pendingVideosForTeamAssignment: [VideoItem] = []
    
    init(sessionManager: SessionManager) {
        UnifiedLogger.info("AuthenticatedContentView init called", context: "AuthenticatedContentView")
        self.sessionManager = sessionManager
        _videoVM = StateObject(wrappedValue: VideoViewModel(sessionManager: sessionManager))
    }
    
    var body: some View {
        UnifiedLogger.info("AuthenticatedContentView body computed", context: "AuthenticatedContentView")
        
        let baseContent = ZStack {
            videoGrid
            floatingAddButton
        }
        .navigationTitle("Videos")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button("View Teams") {
                        UnifiedLogger.info("View Teams tapped", context: "AuthenticatedContentView")
                        showingTeamList = true
                    }
                    Button("Sign Out") {
                        UnifiedLogger.info("Sign Out tapped", context: "AuthenticatedContentView")
                        sessionManager.signOut()
                    }
                } label: {
                    Image(systemName: "line.horizontal.3")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    UnifiedLogger.info("Filter button tapped", context: "AuthenticatedContentView")
                    showingFilterSheet = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        
        let withTeamListSheet = baseContent.sheet(isPresented: $showingTeamList) {
            TeamListView()
                .environmentObject(teamViewModel)
        }
        
        let withVideoSheet = withTeamListSheet.sheet(item: $activeVideo) { vid in
            VideoPlayerModalView(videoItem: vid, videoVM: videoVM)
        }
        
        let withFilterSheet = withVideoSheet.sheet(isPresented: $showingFilterSheet) {
            FilterSheet(
                videoVM: videoVM,
                userTeams: teamViewModel.alphabeticalTeams
            ) {
                UnifiedLogger.info("FilterSheet dismissed", context: "AuthenticatedContentView")
                showingFilterSheet = false
            }
        }
        
        let withTeamPickerSheet = withFilterSheet.sheet(isPresented: $showingTeamPickerSheet) {
            TeamPickerSheet(
                teams: teamViewModel.alphabeticalTeams,
                videosNeedingTeam: $pendingVideosForTeamAssignment
            ) {
                UnifiedLogger.info("TeamPickerSheet completion called, finalizing new videos", context: "AuthenticatedContentView")
                videoVM.finalizeNewVideos(pendingVideosForTeamAssignment)
                pendingVideosForTeamAssignment.removeAll()
                showingTeamPickerSheet = false
            }
        }
        
        let withDuplicateAlert = withTeamPickerSheet.alert(
            duplicateCount == 1 ? "Duplicate Video" : "Duplicate Videos",
            isPresented: $showDuplicateAlert
        ) {
            Button("OK", role: .cancel) {
                UnifiedLogger.info("Duplicate alert OK tapped", context: "AuthenticatedContentView")
            }
        } message: {
            if duplicateCount == 1 {
                Text("You selected 1 video that was already uploaded.")
            } else {
                Text("You selected \(duplicateCount) videos that were already uploaded.")
            }
        }
        
        let finalView = withDuplicateAlert.onChange(of: selectedItems) { oldValue, newValue in
            UnifiedLogger.info("onChange of selectedItems triggered. oldValue count: \(oldValue.count), newValue count: \(newValue.count)", context: "AuthenticatedContentView")
            Task {
                let (newlyAdded, duplicates) = await videoVM.handleNewSelections(newValue)
                UnifiedLogger.info("handleNewSelections returned. newlyAdded count: \(newlyAdded.count), duplicates: \(duplicates)", context: "AuthenticatedContentView")
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
        
        return finalView
    }
    
    private var videoGrid: some View {
        UnifiedLogger.info("videoGrid computed", context: "AuthenticatedContentView")
        
        return ScrollView {
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
                    ForEach(videoVM.displayedVideos) { vid in
                        Button {
                            UnifiedLogger.info("Video tapped: \(vid.id). Refreshing summary...", context: "AuthenticatedContentView")
                            Task {
                                let updated = await videoVM.refreshSummary(for: vid)
                                UnifiedLogger.info("refreshSummary returned for video: \(vid.id). Replacing local video...", context: "AuthenticatedContentView")
                                videoVM.replaceLocalVideo(updated)
                                activeVideo = updated
                                UnifiedLogger.info("Set activeVideo to updated video: \(updated.id)", context: "AuthenticatedContentView")
                            }
                        } label: {
                            vid.thumbnailImage
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

struct AuthenticatedContentViewWrapper: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var teamViewModel: TeamViewModel
    
    var body: some View {
        AuthenticatedContentView(sessionManager: sessionManager)
            .environmentObject(teamViewModel)
    }
}

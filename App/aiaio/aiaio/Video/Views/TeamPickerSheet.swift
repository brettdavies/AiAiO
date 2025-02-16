import SwiftUI

struct TeamPickerSheet: View {
    let teams: [Team]
    @Binding var videosNeedingTeam: [VideoItem]
    
    /// A closure to call when the user taps "Done."
    let onDismiss: () -> Void
    
    /// Determines whether all videos have a team.
    private var allVideosAssigned: Bool {
        videosNeedingTeam.allSatisfy { $0.team != nil }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if videosNeedingTeam.isEmpty {
                    Text("No Videos to Assign")
                        .foregroundStyle(.secondary)
                } else {
                    List(videosNeedingTeam.indices, id: \.self) { index in
                        let video = videosNeedingTeam[index]
                        HStack {
                            // Use the computed thumbnailImage for SwiftUI rendering.
                            video.thumbnailImage
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipped()
                            
                            if let assignedTeam = video.team {
                                Menu(assignedTeam.name) {
                                    ForEach(teams, id: \.id) { team in
                                        Button(team.name) {
                                            videosNeedingTeam[index].team = team
                                        }
                                    }
                                }
                            } else {
                                Menu("Pick Team") {
                                    ForEach(teams, id: \.id) { team in
                                        Button(team.name) {
                                            videosNeedingTeam[index].team = team
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Assign Teams")
            .toolbar {
                // "Assign All" menu to bulk-assign one team to every video.
                ToolbarItem(placement: .navigationBarLeading) {
                    if !videosNeedingTeam.isEmpty {
                        Menu("Assign All") {
                            ForEach(teams, id: \.id) { team in
                                Button(team.name) {
                                    for i in videosNeedingTeam.indices {
                                        videosNeedingTeam[i].team = team
                                    }
                                }
                            }
                        }
                    }
                }
                // "Done" button, disabled if any video is missing a team.
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .disabled(!allVideosAssigned)
                }
            }
        }
    }
}

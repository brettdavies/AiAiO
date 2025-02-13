import SwiftUI

/// A sheet that assigns each newly added video to exactly one team.
struct TeamPickerSheet: View {
    let teams: [Team]
    @Binding var videosNeedingTeam: [VideoItem]
    
    /// A closure to call when the user is done picking teams.
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            // Wrap the if/else in a Group, so SwiftUI unifies them into a single `View` type
            Group {
                if videosNeedingTeam.isEmpty {
                    Text("No Videos to Assign")
                } else {
                    List(videosNeedingTeam.indices, id: \.self) { index in
                        let video = videosNeedingTeam[index]
                        HStack {
                            video.thumbnail
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipped()
                            Text("Select a team for this video")
                            Spacer()
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
            .navigationTitle("Assign Teams")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

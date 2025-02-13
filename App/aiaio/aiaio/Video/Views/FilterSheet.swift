import SwiftUI

/// A sheet that lets the user pick a sort order and filter videos by teams.
struct FilterSheet: View {
    @ObservedObject var videoVM: VideoViewModel
    let userTeams: [Team]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sort Order") {
                    Picker("Sort", selection: $videoVM.sortOrder) {
                        Text("Ascending").tag(VideoSortOrder.ascending)
                        Text("Descending").tag(VideoSortOrder.descending)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Filter by Teams") {
                    ForEach(userTeams, id: \.id) { team in
                        HStack {
                            Text(team.name)
                            Spacer()
                            if videoVM.selectedFilterTeams.contains(team) {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if videoVM.selectedFilterTeams.contains(team) {
                                videoVM.selectedFilterTeams.remove(team)
                            } else {
                                videoVM.selectedFilterTeams.insert(team)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Videos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss via Xcode's "magic" approach
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
                }
            }
        }
    }
}
import SwiftUI

struct TeamListView: View {
    @EnvironmentObject var teamViewModel: TeamViewModel
    // When a team is selected (either an existing one or a new team), we present the detail view modally.
    @State private var selectedTeam: Team?

    var body: some View {
        NavigationStack {
            Group {
                if teamViewModel.isLoading {
                    ProgressView("Loading Teams...")
                } else if teamViewModel.teams.isEmpty {
                    Text("No teams found.")
                } else {
                    List(teamViewModel.alphabeticalTeams) { team in
                        Button {
                            // Edit existing team
                            selectedTeam = team
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(team.name)
                                    .font(.headline)
                                Text(team.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Create new team: use the convenience initializer.
                        selectedTeam = Team.new()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        // Use .sheet(item:) to present the detail view modally.
        .sheet(item: $selectedTeam) { team in
            NavigationStack {
                TeamDetailView(team: team, teamViewModel: teamViewModel, onDismiss: {
                    selectedTeam = nil
                })
                .environmentObject(teamViewModel)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            selectedTeam = nil
                        }
                    }
                }
            }
        }
        .task {
            await teamViewModel.fetchTeams()
        }
    }
}

struct TeamListView_Previews: PreviewProvider {
    static var previews: some View {
        TeamListView()
            .environmentObject(TeamViewModel(sessionManager: SessionManager()))
    }
}

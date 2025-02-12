import SwiftUI

struct TeamListView: View {
    @EnvironmentObject var teamViewModel: TeamViewModel    
    @State private var isPresentingNewTeam = false
    
    var body: some View {
        NavigationStack {
            if teamViewModel.isLoading {
                ProgressView("Loading Teams...")
            } else if teamViewModel.teams.isEmpty {
                Text("No teams found.")
            } else {
                List(teamViewModel.teams) { team in
                    NavigationLink(
                        destination: TeamDetailView(team: team, teamViewModel: teamViewModel)
                            .environmentObject(teamViewModel)
                    ) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(team.name)
                                .font(.headline)
                            Text(team.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Teams")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isPresentingNewTeam = true
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
                .sheet(isPresented: $isPresentingNewTeam) {
                    NavigationStack {
                        // Present TeamDetailView in creation mode using the convenience initializer.
                        TeamDetailView(team: Team.new(), teamViewModel: teamViewModel, onDismiss: {
                            isPresentingNewTeam = false
                        })
                        .environmentObject(teamViewModel)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    isPresentingNewTeam = false
                                }
                            }
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

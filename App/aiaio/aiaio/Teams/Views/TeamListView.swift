import SwiftUI

struct TeamListView: View {
    @EnvironmentObject var teamViewModel: TeamViewModel

    // In a real app, teams would be fetched from Firestore.
    @State private var teams: [Team] = [
        Team(
            id: "1",
            name: "U10 Soccer Team",
            description: "Our U10 soccer team for the season.",
            ownerUID: "1",
            members: ["1": true],
            createdAt: Date(),
            updatedAt: Date()
        ),
        Team(
            id: "2",
            name: "U12 Basketball Team",
            description: "Team roster for the U12 basketball team.",
            ownerUID: "2",
            members: ["2": true],
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    @State private var isPresentingNewTeam = false
    
    var body: some View {
        NavigationStack {
            List(teams) { team in
                NavigationLink(
                    destination: TeamDetailView(team: team)
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
                    TeamDetailView(team: Team.new(), onDismiss: {
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
}

struct TeamListView_Previews: PreviewProvider {
    static var previews: some View {
        TeamListView()
            .environmentObject(TeamViewModel(sessionManager: SessionManager()))
    }
}

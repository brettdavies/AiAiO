import SwiftUI

struct GroupListView: View {
    // In a real app, this list would be fetched from Firestore.
    @State private var groups: [Group] = [
        Group(id: "1", name: "U10 Soccer Team", description: "Our U10 soccer team for the season."),
        Group(id: "2", name: "U12 Basketball Team", description: "Team roster for the U12 basketball team.")
    ]
    
    @State private var isPresentingNewGroup = false

    var body: some View {
        NavigationStack {
            List(groups) { group in
                NavigationLink(destination: GroupDetailView(group: group)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.name)
                            .font(.headline)
                        Text(group.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresentingNewGroup = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .sheet(isPresented: $isPresentingNewGroup, content: {
                NavigationStack {
                    // Present GroupDetailView in creation mode with empty fields.
                    GroupDetailView(group: Group(id: UUID().uuidString, name: "", description: ""))
                        .toolbar(content: {
                            ToolbarItem(placement: .cancellationAction, content: {
                                Button("Cancel", action: {
                                    isPresentingNewGroup = false
                                })
                            })
                        })
                }
            })
        }
    }
}

struct GroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupListView()
    }
}

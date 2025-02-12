import SwiftUI

struct TeamDetailView: View {
    /// The team being created or edited.
    @State var team: Team

    /// Persist whether this view is in "create" mode.
    private let isCreating: Bool
    /// Track if the user has attempted to save (to trigger validation errors).
    @State private var hasAttemptedSave = false
    @State private var showValidationError = false

    /// Access the team view model from the environment.
    @EnvironmentObject var teamViewModel: TeamViewModel

    /// Toast state.
    @State private var showToast = false
    @State private var toastMessage: String = ""
    
    /// Closure to dismiss the view.
    var onDismiss: () -> Void = {}

    /// Computed property: both fields must have non‑empty trimmed values.
    var isFormValid: Bool {
        !team.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !team.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Custom initializer that captures the initial state for "create" mode.
    /// If both name and description are empty initially, we consider this a new team.
    init(team: Team, onDismiss: @escaping () -> Void = {}) {
        _team = State(initialValue: team)
        self.onDismiss = onDismiss
        isCreating = team.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
            && team.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        Form {
            Section(header: Text("Team Details")) {
                // Team Name field with a clear ("x") button.
                HStack {
                    TextField("Team Name", text: $team.name)
                        .autocapitalization(.words)
                    if !team.name.isEmpty {
                        Button(
                            action: { team.name = "" },
                            label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        )
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                if hasAttemptedSave && 
                    team.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Team Name is required")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Description field with a clear ("x") button.
                HStack {
                    TextField("Description", text: $team.description)
                    if !team.description.isEmpty {
                        Button(
                            action: { team.description = "" },
                            label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        )
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                if hasAttemptedSave && 
                    team.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Description is required")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle(isCreating ? "Create Team" : "Edit Team")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    hasAttemptedSave = true
                    if isFormValid {
                        Task {
                            if isCreating {
                                if await teamViewModel.createTeam(
                                    name: team.name,
                                    description: team.description
                                ) != nil {
                                    toastMessage = "Team Created"
                                    withAnimation { showToast = true }
                                    try await Task.sleep(nanoseconds: 1_000_000_000)
                                    onDismiss()
                                } else {
                                    toastMessage = "Failed to create team"
                                    withAnimation { showToast = true }
                                    try await Task.sleep(nanoseconds: 1_000_000_000)
                                }
                            } else {
                                let success = await teamViewModel.updateTeam(
                                    team,
                                    userUID: team.ownerUID
                                )
                                if success {
                                    toastMessage = "Team Updated"
                                    withAnimation { showToast = true }
                                    try await Task.sleep(nanoseconds: 1_000_000_000)
                                    onDismiss()
                                } else {
                                    toastMessage = "Failed to update team"
                                    withAnimation { showToast = true }
                                    try await Task.sleep(nanoseconds: 1_000_000_000)
                                }
                            }
                        }
                    } else {
                        showValidationError = true
                    }
                }
                .disabled(!isFormValid)
            }
        }
        .alert(isPresented: $showValidationError) {
            Alert(title: Text("Validation Error"),
                  message: Text("Please fill in all required fields."),
                  dismissButton: .default(Text("OK")))
        }
        .overlay(
            Group {
                if showToast {
                    VStack {
                        Text(toastMessage)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding()
                    .transition(.opacity)
                }
            }
        )
    }
}

struct TeamDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TeamDetailView(team: Team.new())
            .environmentObject(TeamViewModel(sessionManager: SessionManager()))
    }
}

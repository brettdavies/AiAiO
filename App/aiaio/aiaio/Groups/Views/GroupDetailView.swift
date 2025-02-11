import SwiftUI

struct GroupDetailView: View {
    // The group being created or edited.
    @State var group: Group

    // Persist whether this view is in "create" mode.
    private let isCreating: Bool
    // Track if the user has attempted to save.
    @State private var hasAttemptedSave = false
    @State private var showValidationError = false

    // Computed property: both fields must have non‑empty trimmed values.
    var isFormValid: Bool {
        !group.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !group.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // Custom initializer that determines if this is a new group.
    init(group: Group) {
        _group = State(initialValue: group)
        // Capture the initial state so that if both fields start empty, we remain in "create" mode.
        isCreating = group.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                     group.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section(header: Text("Group Details")) {
                // Group Name field with clear ("x") button.
                HStack {
                    TextField("Group Name", text: $group.name)
                        .autocapitalization(.words)
                    if !group.name.isEmpty {
                        Button(action: {
                            group.name = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                // Show validation error only if the user has attempted to save.
                if hasAttemptedSave && group.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Group Name is required")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Description field with clear ("x") button.
                HStack {
                    TextField("Description", text: $group.description)
                    if !group.description.isEmpty {
                        Button(action: {
                            group.description = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                if hasAttemptedSave && group.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Description is required")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle(isCreating ? "Create Group" : "Edit Group")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    hasAttemptedSave = true
                    if isFormValid {
                        // TODO: Implement save logic (e.g., update Firestore).
                        UnifiedLogger.log("Group \(group.id) saved. Name: \(group.name)", level: .info)
                        // Optionally, dismiss the view here.
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
    }
}

struct GroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview for editing (non-empty values) and for creating (empty values) as needed.
        GroupDetailView(group: Group(id: "1", name: "", description: ""))
    }
}

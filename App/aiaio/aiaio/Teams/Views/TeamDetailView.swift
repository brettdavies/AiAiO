import SwiftUI

struct TeamDetailView: View {
    @StateObject private var viewModel: TeamDetailViewModel
    var onDismiss: () -> Void = {}
    
    init(team: Team, teamViewModel: TeamViewModel, onDismiss: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: TeamDetailViewModel(team: team, teamViewModel: teamViewModel))
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        Form {
            Section(header: Text("Team Details")) {
                teamNameField
                descriptionField
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        if await viewModel.handleSave() {
                            onDismiss()
                        }
                    }
                }
                .disabled(!viewModel.isFormValid || !viewModel.hasChanges)
            }
        }
        .alert(isPresented: $viewModel.showValidationError) {
            Alert(
                title: Text("Validation Error"),
                message: Text("Please fill in all required fields and make changes before saving."),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay(
            Group {
                if viewModel.showToast {
                    VStack {
                        Text(viewModel.toastMessage)
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
        .animation(.easeInOut, value: viewModel.showToast)
    }
    
    @ViewBuilder private var teamNameField: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Team Name", text: $viewModel.team.name)
                    .textInputAutocapitalization(.words)
                if !viewModel.team.name.isEmpty {
                    ClearButton {
                        viewModel.clearField(\.name)
                    }
                }
            }
            if !viewModel.validateField(\.name) {
                ValidationErrorText(message: "Team Name is required")
            }
        }
    }
    
    @ViewBuilder private var descriptionField: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Description", text: $viewModel.team.description)
                if !viewModel.team.description.isEmpty {
                    ClearButton {
                        viewModel.clearField(\.description)
                    }
                }
            }
            if !viewModel.validateField(\.description) {
                ValidationErrorText(message: "Description is required")
            }
        }
    }
}

private struct ClearButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

private struct ValidationErrorText: View {
    let message: String
    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .font(.caption)
    }
}

struct TeamDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TeamDetailView(team: Team.new(), teamViewModel: TeamViewModel(sessionManager: SessionManager()))
    }
}

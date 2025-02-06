import SwiftUI

struct SignUpView: View {
    // MARK: - Properties
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(
                        NSLocalizedString("auth.email.placeholder", comment: ""),
                        text: $viewModel.email
                    )
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    SecureField(
                        NSLocalizedString("auth.password.placeholder", comment: ""),
                        text: $viewModel.password
                    )
                    .textContentType(.newPassword)

                    SecureField(
                        NSLocalizedString("auth.confirm_password.placeholder", comment: ""),
                        text: $viewModel.confirmPassword
                    )
                    .textContentType(.newPassword)
                } header: {
                    Text(NSLocalizedString("auth.signup.credentials.header", comment: ""))
                }

                Section {
                    Button {
                        Task {
                            await viewModel.signUp()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text(NSLocalizedString("auth.signup.button", comment: ""))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!viewModel.isSignUpFormValid || viewModel.isLoading)
                }

                Section {
                    Button {
                        dismiss()
                    } label: {
                        Text(NSLocalizedString("auth.signin.existing_account", comment: ""))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(Text(NSLocalizedString("auth.signup.title", comment: "")))
            .alert(isPresented: .constant(viewModel.error != nil)) {
                Alert(
                    title: Text("auth.error.title"),
                    message: Text(viewModel.error?.localizedDescription ?? ""),
                    dismissButton: .default(Text("common.ok")) {
                        viewModel.error = nil
                    }
                )
            }
        }
    }
}

#Preview {
    SignUpView()
}

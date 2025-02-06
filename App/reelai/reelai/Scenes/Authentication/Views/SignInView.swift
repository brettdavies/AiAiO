import GoogleSignInSwift
import SwiftUI

struct SignInView: View {
    // MARK: - Properties
    @StateObject private var viewModel = AuthViewModel()
    @State private var showingSignUp = false
    @State private var showingPasswordReset = false

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
                    .textContentType(.password)
                } header: {
                    Text(NSLocalizedString("auth.signin.credentials.header", comment: ""))
                }

                Section {
                    GoogleSignInButton(
                        viewModel: GoogleSignInButtonViewModel(
                            scheme: .dark,
                            style: .wide,
                            state: viewModel.isLoading ? .disabled : .normal
                        )
                    ) {
                        Task {
                            await viewModel.signInWithGoogle()
                        }
                    }
                    .frame(height: 44)
                } header: {
                    Text(NSLocalizedString("auth.signin.social.header", comment: ""))
                }

                Section {
                    Button {
                        Task {
                            await viewModel.signIn()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text(NSLocalizedString("auth.signin.button", comment: ""))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!viewModel.isSignInFormValid || viewModel.isLoading)
                }

                Section {
                    Button {
                        showingSignUp = true
                    } label: {
                        Text(NSLocalizedString("auth.signup.create_account", comment: ""))
                    }

                    Button {
                        showingPasswordReset = true
                    } label: {
                        Text(NSLocalizedString("auth.password.reset", comment: ""))
                    }
                }
            }
            .navigationTitle(Text(NSLocalizedString("auth.signin.title", comment: "")))
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .alert(
                NSLocalizedString("auth.password.reset.title", comment: ""),
                isPresented: $showingPasswordReset
            ) {
                TextField(
                    NSLocalizedString("auth.email.placeholder", comment: ""),
                    text: $viewModel.email)
                Button(NSLocalizedString("auth.password.reset.send", comment: "")) {
                    Task {
                        await viewModel.sendPasswordReset()
                    }
                }
                Button(NSLocalizedString("common.cancel", comment: ""), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("auth.password.reset.message", comment: ""))
            }
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
    SignInView()
}

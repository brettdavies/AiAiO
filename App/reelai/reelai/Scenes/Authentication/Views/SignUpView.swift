@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore
import SwiftUI

struct SignUpView: View {
    // MARK: - Properties
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        authService: AuthService,
        environment: FirebaseEnvironment.Environment = .development
    ) {
        let viewModel = AuthViewModel(authService: authService, environment: environment)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Email field
                TextField(
                    NSLocalizedString("auth.email.placeholder", comment: ""), text: $viewModel.email
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)

                // Password field
                SecureField(
                    NSLocalizedString("auth.password.placeholder", comment: ""),
                    text: $viewModel.password
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.newPassword)

                // Confirm Password field
                SecureField(
                    NSLocalizedString("auth.confirm_password.placeholder", comment: ""),
                    text: $viewModel.confirmPassword
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.newPassword)

                // Sign Up button
                Button(action: {
                    Task {
                        await viewModel.signUp()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text(NSLocalizedString("auth.signup.button", comment: ""))
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || !viewModel.isValid)

                // Terms of Service text
                Text(NSLocalizedString("auth.signup.terms", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                // Divider
                Divider()
                    .padding(.vertical)

                // Sign In link
                Button(action: {
                    dismiss()
                }) {
                    Text(NSLocalizedString("auth.signup.existing_account", comment: ""))
                }
            }
            .padding()
            .navigationTitle(NSLocalizedString("auth.signup.title", comment: ""))
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

//#Preview("Default") {
//    SignUpView(authService: PreviewAuthService())
//}
//
//#Preview("Loading") {
//    let service = PreviewAuthService()
//    let viewModel = AuthViewModel(authService: service)
//    viewModel.isLoading = true
//    return SignUpView(authService: service)
//}
//
//#Preview("Error") {
//    let service = PreviewAuthService()
//    let viewModel = AuthViewModel(authService: service)
//    viewModel.error = AuthError.invalidEmail("Invalid email")
//    return SignUpView(authService: service)
//}

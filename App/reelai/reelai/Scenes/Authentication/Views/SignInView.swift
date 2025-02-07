@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore
import Foundation
import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        authService: AuthService,
        environment: FirebaseEnvironment.Environment = .development
    ) {
        let viewModel = AuthViewModel(authService: authService, environment: environment)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Email field
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                // Password field
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)

                // Sign In button
                Button(action: {
                    Task {
                        await viewModel.signIn()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading || !viewModel.isValid)

                // Divider
                Divider()
                    .padding(.vertical)

                // Sign Up link
                NavigationLink(
                    destination: SignUpView(
                        authService: viewModel.authService,
                        environment: viewModel.environment
                    )
                ) {
                    Text("Don't have an account? Sign Up")
                }

                // Forgot Password link
                Button("Forgot Password?") {
                    Task {
                        await viewModel.sendPasswordReset()
                    }
                }
                .disabled(viewModel.email.isEmpty)
            }
            .padding()
            .navigationTitle("Sign In")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
            .alert("Success", isPresented: $viewModel.showResetSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Password reset email sent")
            }
        }
    }
}
//
//#Preview("Default") {
//    SignInView(authService: PreviewAuthService())
//}
//
//#Preview("Loading") {
//    let service = PreviewAuthService()
//    let viewModel = AuthViewModel(authService: service)
//    viewModel.isLoading = true
//    return SignInView(authService: service)
//}
//
//#Preview("Error") {
//    let service = PreviewAuthService()
//    let viewModel = AuthViewModel(authService: service)
//    viewModel.error = AuthError.invalidEmail("Invalid email")
//    return SignInView(authService: service)
//}

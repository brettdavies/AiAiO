import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import SwiftUI

/// A view model that handles authentication-related operations and state
@MainActor
public final class AuthViewModel: ObservableObject {
    // MARK: - Properties
    let authService: AuthService
    let environment: FirebaseEnvironment.Environment

    // State
    @Published var isInitialized = false
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showError = false
    @Published var showResetSuccess = false

    // User state
    @Published var currentUser: FirestoreUser?
    @Published var isAuthenticated = false

    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    // Validation
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    // New properties
    @Published var isRefreshing = false
    @Published var successMessage = ""

    // MARK: - Initialization
    init(
        authService: AuthService,
        environment: FirebaseEnvironment.Environment = .development
    ) {
        self.authService = authService
        self.environment = environment
    }

    // MARK: - Public Methods
    func initialize() {
        Task {
            do {
                isLoading = true

                // Initialize Firebase
                try await FirebaseClient.shared.initialize(environment: environment)

                // Check if we have a user
                if authService.isAuthenticated {
                    currentUser = try await authService.getCurrentUser()
                    isAuthenticated = true
                }

                isInitialized = true
                isLoading = false
            } catch {
                self.error = error
                showError = true
                isLoading = false
            }
        }
    }

    func signIn() async {
        do {
            isLoading = true
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            isLoading = false
        } catch {
            self.error = error
            showError = true
            isLoading = false
        }
    }

    func signUp() async {
        do {
            isLoading = true
            let user = try await authService.signUp(
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )
            currentUser = user
            isAuthenticated = true
            isLoading = false
        } catch {
            self.error = error
            showError = true
            isLoading = false
        }
    }

    func signOut() {
        Task {
            do {
                isLoading = true
                try await authService.signOut()
                currentUser = nil
                isAuthenticated = false
                isLoading = false
            } catch {
                self.error = error
                showError = true
                isLoading = false
            }
        }
    }

    func sendPasswordReset() async {
        do {
            isLoading = true
            try await authService.sendPasswordReset(to: email)
            showResetSuccess = true
            isLoading = false
        } catch {
            self.error = error
            showError = true
            isLoading = false
        }
    }

    func refreshEmailVerification() async {
        do {
            isLoading = true
            currentUser = try await authService.refreshEmailVerificationStatus()
            isLoading = false
        } catch {
            self.error = error
            showError = true
            isLoading = false
        }
    }

    func refreshEmailVerificationStatus() async {
        do {
            isRefreshing = true
            currentUser = try await authService.refreshEmailVerificationStatus()
            isRefreshing = false
        } catch {
            self.error = error
            showError = true
            isRefreshing = false
        }
    }

    func resendEmailVerification() async {
        do {
            isLoading = true
            try await authService.resendEmailVerification()
            successMessage = NSLocalizedString("auth.verify.email.sent", comment: "")
            isLoading = false
        } catch {
            self.error = error
            showError = true
            isLoading = false
        }
    }
}

// // MARK: - Preview Helpers
// #if DEBUG
//     actor PreviewAuthService: AuthProviding {
//         nonisolated var currentUserId: String? { "preview-id" }
//         nonisolated var isAuthenticated: Bool { true }

//         func signUp(email: String, password: String, confirmPassword: String) async throws
//             -> FirestoreUser
//         {
//             FirestoreUser(
//                 id: "preview-id",
//                 email: email,
//                 createdAt: Date(),
//                 isEmailVerified: false,
//                 displayName: nil,
//                 photoURL: nil
//             )
//         }

//         func signIn(email: String, password: String) async throws -> FirestoreUser {
//             FirestoreUser(
//                 id: "preview-id",
//                 email: email,
//                 createdAt: Date(),
//                 isEmailVerified: true,
//                 displayName: nil,
//                 photoURL: nil
//             )
//         }

//         func signOut() async throws {}
//         func sendPasswordReset(to email: String) async throws {}
//         func resendEmailVerification() async throws {}

//         func refreshEmailVerificationStatus() async throws -> FirestoreUser {
//             FirestoreUser(
//                 id: "preview-id",
//                 email: "preview@example.com",
//                 createdAt: Date(),
//                 isEmailVerified: true,
//                 displayName: nil,
//                 photoURL: nil
//             )
//         }

//         func updateProfile(displayName: String?, photoURL: URL?) async throws {}

//         func getCurrentUser() async throws -> FirestoreUser {
//             FirestoreUser(
//                 id: "preview-id",
//                 email: "preview@example.com",
//                 createdAt: Date(),
//                 isEmailVerified: true,
//                 displayName: nil,
//                 photoURL: nil
//             )
//         }
//     }

//     extension AuthViewModel {
//         static var preview: AuthViewModel {
//             let service = PreviewAuthService()
//             return AuthViewModel(authService: service)
//         }

//         static var previewLoading: AuthViewModel {
//             let service = PreviewAuthService()
//             let viewModel = AuthViewModel(authService: service)
//             viewModel.isLoading = true
//             return viewModel
//         }

//         static var previewError: AuthViewModel {
//             let service = PreviewAuthService()
//             let viewModel = AuthViewModel(authService: service)
//             viewModel.error = AuthError.invalidEmail("Invalid email")
//             viewModel.showError = true
//             return viewModel
//         }

//         static var previewUnverified: AuthViewModel {
//             let service = PreviewAuthService()
//             let viewModel = AuthViewModel(authService: service)
//             viewModel.currentUser = FirestoreUser(
//                 id: "preview-id",
//                 email: "preview@example.com",
//                 createdAt: Date(),
//                 isEmailVerified: false,
//                 displayName: nil,
//                 photoURL: nil
//             )
//             viewModel.isAuthenticated = true
//             return viewModel
//         }

//         static var previewVerified: AuthViewModel {
//             let service = PreviewAuthService()
//             let viewModel = AuthViewModel(authService: service)
//             viewModel.currentUser = FirestoreUser(
//                 id: "preview-id",
//                 email: "preview@example.com",
//                 createdAt: Date(),
//                 isEmailVerified: true,
//                 displayName: "Preview User",
//                 photoURL: nil
//             )
//             viewModel.isAuthenticated = true
//             return viewModel
//         }
//     }
// #endif

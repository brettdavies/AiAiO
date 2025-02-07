// @preconcurrency import FirebaseAuth
// @preconcurrency import FirebaseFirestore
// // Import protocols
// import Foundation
// import SwiftUI

// #if DEBUG
//     /// Mock implementations for previews
//     @MainActor
//     final class PreviewAuthService: AuthProviding {
//         static let shared = PreviewAuthService()
//         private let authService: AuthService = AuthService()

//         // Different user states for previews
//         enum PreviewUserState: Sendable {
//             case signedOut
//             case signedInUnverified
//             case signedInVerified
//             case signedInWithGoogle
//             case error(AuthError)
//         }

//         // Different mock users for testing
//         static let mockUsers: [FirestoreUser] = [
//             FirestoreUser(
//                 id: "preview-unverified-user",
//                 email: "unverified@example.com",
//                 createdAt: Date(),
//                 isEmailVerified: false,
//                 displayName: nil,
//                 photoURL: nil
//             ),
//             FirestoreUser(
//                 id: "preview-verified-user",
//                 email: "verified@example.com",
//                 createdAt: Date(),
//                 isEmailVerified: true,
//                 displayName: "Verified User",
//                 photoURL: nil
//             ),
//             FirestoreUser(
//                 id: "preview-google-user",
//                 email: "google@gmail.com",
//                 createdAt: Date(),
//                 isEmailVerified: true,
//                 displayName: "Google User",
//                 photoURL: URL(string: "https://example.com/avatar.jpg")
//             ),
//         ]

//         // Configurable state for previews
//         private(set) var currentState: PreviewUserState = .signedOut
//         private(set) var mockUser: FirestoreUser?
//         private(set) var isLoading: Bool = false
//         private(set) var error: AuthError?

//         // Preview-specific getters
//         var currentUserId: String? {
//             switch currentState {
//             case .signedOut, .error:
//                 return nil
//             default:
//                 return mockUser?.id ?? "preview-user-id"
//             }
//         }

//         var isAuthenticated: Bool {
//             switch currentState {
//             case .signedOut, .error:
//                 return false
//             default:
//                 return true
//             }
//         }

//         func setState(_ state: PreviewUserState, mockUser: FirestoreUser? = nil) {
//             self.currentState = state
//             self.mockUser = mockUser
//         }

//         func setLoading(_ loading: Bool) {
//             self.isLoading = loading
//         }

//         func setError(_ error: AuthError?) {
//             self.error = error
//         }

//         // MARK: - AuthProviding Protocol Implementation
//         func signOut() async throws {
//             setState(.signedOut)
//         }

//         func sendPasswordReset(to email: String) async throws {
//             // Simulate password reset
//             try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second delay
//         }

//         func resendEmailVerification() async throws {
//             guard mockUser != nil else {
//                 throw AuthError.userNotFound(
//                     NSLocalizedString("auth.error.user_not_found", comment: ""))
//             }
//             // Simulate email verification
//             try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second delay
//         }

//         func refreshEmailVerificationStatus() async throws -> FirestoreUser {
//             guard let mockUser = mockUser else {
//                 throw AuthError.userNotFound(
//                     NSLocalizedString("auth.error.user_not_found", comment: ""))
//             }
//             return mockUser
//         }

//         func updateProfile(displayName: String? = nil, photoURL: URL? = nil) async throws {
//             guard var mockUser = mockUser else {
//                 throw AuthError.userNotFound(
//                     NSLocalizedString("auth.error.user_not_found", comment: ""))
//             }
//             // Update mock user
//             mockUser = FirestoreUser(
//                 id: mockUser.id,
//                 email: mockUser.email,
//                 createdAt: mockUser.createdAt,
//                 isEmailVerified: mockUser.isEmailVerified,
//                 displayName: displayName ?? mockUser.displayName,
//                 photoURL: photoURL ?? mockUser.photoURL
//             )
//             self.mockUser = mockUser
//         }

//         func getCurrentUser() async throws -> FirestoreUser {
//             guard let mockUser = mockUser else {
//                 throw AuthError.userNotFound(
//                     NSLocalizedString("auth.error.user_not_found", comment: ""))
//             }
//             return mockUser
//         }

//         func signUp(email: String, password: String, confirmPassword: String) async throws
//             -> FirestoreUser
//         {
//             try GlobalValidator.validateSignUp(
//                 email: email, password: password, confirmPassword: confirmPassword)

//             let user = FirestoreUser(
//                 id: UUID().uuidString,
//                 email: email,
//                 createdAt: Date(),
//                 isEmailVerified: false,
//                 displayName: nil,
//                 photoURL: nil
//             )
//             setState(.signedInUnverified, mockUser: user)
//             return user
//         }

//         func signIn(email: String, password: String) async throws -> FirestoreUser {
//             try GlobalValidator.validateSignIn(email: email, password: password)

//             // Simulate successful sign in with the first mock user
//             let user = PreviewAuthService.mockUsers[0]
//             setState(.signedInUnverified, mockUser: user)
//             return user
//         }
//     }

//     extension AuthViewModel {
//         // Different preview states for the ViewModel
//         static var preview: AuthViewModel {
//             let viewModel = AuthViewModel(
//                 authService: PreviewAuthService.shared as AuthProviding,
//                 environment: .development
//             )

//             // Set default preview state
//             viewModel.email = "test@example.com"
//             viewModel.isLoading = false
//             viewModel.error = nil

//             return viewModel
//         }

//         // Additional preview states
//         static var previewLoading: AuthViewModel {
//             let viewModel = preview
//             viewModel.isLoading = true
//             return viewModel
//         }

//         static var previewError: AuthViewModel {
//             let viewModel = preview
//             viewModel.error = AuthError.invalidEmail(
//                 NSLocalizedString("auth.error.invalid_email", comment: ""))
//             return viewModel
//         }

//         static var previewUnverified: AuthViewModel {
//             let viewModel = preview
//             PreviewAuthService.shared.setState(
//                 .signedInUnverified, mockUser: PreviewAuthService.mockUsers[0])
//             return viewModel
//         }

//         static var previewVerified: AuthViewModel {
//             let viewModel = preview
//             PreviewAuthService.shared.setState(
//                 .signedInVerified, mockUser: PreviewAuthService.mockUsers[1])
//             return viewModel
//         }
//     }

//     // MARK: - Preview State Management
//     /// Defines possible preview states for authentication
//     enum AuthPreviewState: Sendable {
//         case signedOut
//         case loading
//         case error(AuthError)
//         case authenticated(FirestoreUser)

//         /// Default preview user for authenticated state
//         static let previewUser = FirestoreUser(
//             id: "preview-id",
//             email: "preview@example.com",
//             createdAt: Date(),
//             isEmailVerified: true,
//             displayName: "Preview User",
//             photoURL: nil
//         )

//         /// Unverified preview user
//         static let unverifiedUser = FirestoreUser(
//             id: "preview-unverified",
//             email: "unverified@example.com",
//             createdAt: Date(),
//             isEmailVerified: false,
//             displayName: nil,
//             photoURL: nil
//         )
//     }

//     // MARK: - Mock Auth Service
//     /// Provides preview data for authentication flows
//     actor MockAuthService: AuthProviding {
//         // MARK: - Properties
//         private let state: AuthPreviewState

//         // MARK: - Protocol Requirements (thread-safe)
//         nonisolated let currentUserId: String?
//         nonisolated let isAuthenticated: Bool

//         // MARK: - Initialization
//         init(state: AuthPreviewState = .signedOut) {
//             self.state = state

//             // Initialize nonisolated properties based on state
//             switch state {
//             case .signedOut, .loading, .error:
//                 self.currentUserId = nil
//                 self.isAuthenticated = false
//             case .authenticated(let user):
//                 self.currentUserId = user.id
//                 self.isAuthenticated = true
//             }
//         }

//         // MARK: - AuthProviding Methods
//         func signUp(email: String, password: String, confirmPassword: String) async throws
//             -> FirestoreUser
//         {
//             switch state {
//             case .error(let error): throw error
//             case .authenticated(let user): return user
//             case .loading: try await Task.sleep(nanoseconds: 1_000_000_000)
//             case .signedOut: throw AuthError.unknown("Not implemented in preview")
//             }
//             throw AuthError.unknown("Invalid state")
//         }

//         func signIn(email: String, password: String) async throws -> FirestoreUser {
//             switch state {
//             case .error(let error): throw error
//             case .authenticated(let user): return user
//             case .loading: try await Task.sleep(nanoseconds: 1_000_000_000)
//             case .signedOut: throw AuthError.invalidCredentials("Invalid credentials")
//             }
//             throw AuthError.unknown("Invalid state")
//         }

//         func signOut() async throws {
//             switch state {
//             case .error(let error): throw error
//             case .loading: try await Task.sleep(nanoseconds: 1_000_000_000)
//             default: break
//             }
//         }

//         func sendPasswordReset(to email: String) async throws {
//             switch state {
//             case .error(let error): throw error
//             case .loading: try await Task.sleep(nanoseconds: 1_000_000_000)
//             default: break
//             }
//         }

//         func resendEmailVerification() async throws {
//             switch state {
//             case .error(let error): throw error
//             case .loading: try await Task.sleep(nanoseconds: 1_000_000_000)
//             default: break
//             }
//         }

//         func refreshEmailVerificationStatus() async throws -> FirestoreUser {
//             switch state {
//             case .authenticated(let user): return user
//             case .error(let error): throw error
//             case .loading: try await Task.sleep(nanoseconds: 1_000_000_000)
//             case .signedOut: throw AuthError.userNotFound("No user in preview")
//             }
//             throw AuthError.unknown("Invalid state")
//         }

//         func updateProfile(displayName: String?, photoURL: URL?) async throws {
//             switch state {
//             case .error(let error): throw error
//             case .loading: try await Task.sleep(nanoseconds: 1_000_000_000)
//             default: break
//             }
//         }

//         func getCurrentUser() async throws -> FirestoreUser {
//             switch state {
//             case .authenticated(let user): return user
//             case .error(let error): throw error
//             case .loading: try await Task.sleep(nanoseconds: 1_000_000_000)
//             case .signedOut: throw AuthError.userNotFound("No user in preview")
//             }
//             throw AuthError.unknown("Invalid state")
//         }
//     }

//     // MARK: - Preview Helpers
//     extension AuthViewModel {
//         static func preview(state: AuthPreviewState) -> AuthViewModel {
//             let viewModel = AuthViewModel(
//                 authService: MockAuthService(state: state),
//                 environment: .development
//             )

//             // Configure viewModel based on state
//             switch state {
//             case .loading:
//                 viewModel.isLoading = true
//             case .error(let error):
//                 viewModel.error = error
//                 viewModel.showError = true
//             case .authenticated(let user):
//                 viewModel.currentUser = user
//                 viewModel.isAuthenticated = true
//             case .signedOut:
//                 break
//             }

//             return viewModel
//         }

//         static var preview: AuthViewModel { preview(state: .signedOut) }
//         static var previewLoading: AuthViewModel { preview(state: .loading) }
//         static var previewError: AuthViewModel {
//             preview(state: .error(AuthError.invalidEmail("Invalid email")))
//         }
//         static var previewUnverified: AuthViewModel {
//             preview(state: .authenticated(AuthPreviewState.unverifiedUser))
//         }
//         static var previewVerified: AuthViewModel {
//             preview(state: .authenticated(AuthPreviewState.previewUser))
//         }
//     }

//     // MARK: - View Preview Extensions
//     extension SignInView {
//         static var previews: some View {
//             Group {
//                 SignInView(
//                     authService: MockAuthService(state: .signedOut),
//                     environment: .development
//                 )
//                 .previewDisplayName("Default")

//                 SignInView(
//                     authService: MockAuthService(state: .loading),
//                     environment: .development
//                 )
//                 .previewDisplayName("Loading")

//                 SignInView(
//                     authService: MockAuthService(
//                         state: .error(AuthError.invalidEmail("Invalid email"))
//                     ),
//                     environment: .development
//                 )
//                 .previewDisplayName("Error")

//                 SignInView(
//                     authService: MockAuthService(
//                         state: .authenticated(AuthPreviewState.previewUser)
//                     ),
//                     environment: .development
//                 )
//                 .previewDisplayName("Authenticated")
//             }
//         }
//     }
// #endif

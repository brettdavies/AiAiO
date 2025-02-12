import Foundation
@preconcurrency import FirebaseAuth

enum AuthSheet: Identifiable {
    case signIn, signUp
    var id: Int { hashValue }
}

@MainActor
class AuthViewModel: ObservableObject {
    // UI state for the sign-in/sign-up flows.
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    /// Controls which auth modal (sign in or sign up) is active.
    @Published var activeAuthSheet: AuthSheet?

    /// Attempts to sign in using Firebase Auth.
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        do {
            // Firebase async/await sign-in call.
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            isLoading = false
            UnifiedLogger.info("User signed in successfully.", context: "Auth")
        } catch let error as NSError {
            isLoading = false
            let mappedError = mapFirebaseError(error)
            errorMessage = mappedError.errorDescription
            UnifiedLogger.error("Sign in failed: \(mappedError.errorDescription ?? "")", context: "Auth")
            throw mappedError
        }
    }

    /// Attempts to sign up using Firebase Auth.
    func signUp(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        do {
            // Firebase async/await sign-up call.
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
            isLoading = false
            UnifiedLogger.info("User signed up successfully.", context: "Auth")
        } catch let error as NSError {
            isLoading = false
            let mappedError = mapFirebaseError(error)
            errorMessage = mappedError.errorDescription
            UnifiedLogger.error("Sign up failed: \(mappedError.errorDescription ?? "")", context: "Auth")
            throw mappedError
        }
    }

    /// Signs out the current user.
    func signOut() async throws {
        UnifiedLogger.info("Attempting sign out via AuthViewModel.", context: "Auth")
        do {
            try Auth.auth().signOut()
            UnifiedLogger.info("User signed out successfully.", context: "Auth")
        } catch let error as NSError {
            isLoading = false
            let mappedError = mapFirebaseError(error)
            errorMessage = mappedError.errorDescription
            UnifiedLogger.error("Sign out failed: \(mappedError.errorDescription ?? "")", context: "Auth")
            throw mappedError
        }
    }
}

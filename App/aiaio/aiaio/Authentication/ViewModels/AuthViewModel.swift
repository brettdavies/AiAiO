import Foundation
@preconcurrency import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Tracks whether the user is authenticated.
    @Published var isSignedIn: Bool = false
    
    // Controls which auth modal (sign in or sign up) is active.
    @Published var activeAuthSheet: AuthSheet?

    /// Attempts to sign in using Firebase Auth.
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            // Firebase async/await sign-in call.
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            isLoading = false
            isSignedIn = true
            activeAuthSheet = nil // Dismiss any presented auth sheet.
            UnifiedLogger.log("User signed in successfully.", level: .info)
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            UnifiedLogger.log("Sign in failed: \(error.localizedDescription)", level: .error)
        }
    }
    
    /// Attempts to sign up using Firebase Auth.
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            // Firebase async/await sign-up call.
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
            isLoading = false
            isSignedIn = true
            activeAuthSheet = nil // Dismiss any presented auth sheet.
            UnifiedLogger.log("User signed up successfully.", level: .info)
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            UnifiedLogger.log("Sign up failed: \(error.localizedDescription)", level: .error)
        }
    }
    
    /// Signs out the current user.
    func signOut() {
        do {
            try Auth.auth().signOut()
            isSignedIn = false
            UnifiedLogger.log("User signed out successfully.", level: .info)
        } catch {
            errorMessage = error.localizedDescription
            UnifiedLogger.log("Sign out failed: \(error.localizedDescription)", level: .error)
        }
    }
}

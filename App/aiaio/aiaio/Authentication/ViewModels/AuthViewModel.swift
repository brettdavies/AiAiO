import Foundation
@preconcurrency import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    // UI state for the sign-in/sign-up flows.
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?  // Removed redundant initialization
    /// Controls which auth modal (sign in or sign up) is active.
    @Published var activeAuthSheet: AuthSheet?  // Removed redundant initialization

    /// Attempts to sign in using Firebase Auth.
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        do {
            // Firebase async/await sign-in call.
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            isLoading = false
            UnifiedLogger.log("User signed in successfully.", level: .info)
            // Global auth state is handled by SessionManager.
        } catch let err as NSError {
            isLoading = false
            if err.code == AuthErrorCode.invalidEmail.rawValue {
                errorMessage = GlobalError.invalidEmail.errorDescription
                UnifiedLogger.log("Sign in failed: \(GlobalError.invalidEmail.errorDescription ?? "")", level: .error)
                throw GlobalError.invalidEmail
            } else if err.code == AuthErrorCode.weakPassword.rawValue {
                errorMessage = GlobalError.weakPassword.errorDescription
                UnifiedLogger.log("Sign in failed: \(GlobalError.weakPassword.errorDescription ?? "")", level: .error)
                throw GlobalError.weakPassword
            } else {
                let mappedError = GlobalError.unknown(err.localizedDescription)
                errorMessage = mappedError.errorDescription
                UnifiedLogger.log("Sign in failed: \(mappedError.errorDescription ?? "")", level: .error)
                throw mappedError
            }
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
            UnifiedLogger.log("User signed up successfully.", level: .info)
        } catch let err as NSError {
            isLoading = false
            if err.code == AuthErrorCode.invalidEmail.rawValue {
                errorMessage = GlobalError.invalidEmail.errorDescription
                UnifiedLogger.log("Sign up failed: \(GlobalError.invalidEmail.errorDescription ?? "")", level: .error)
                throw GlobalError.invalidEmail
            } else if err.code == AuthErrorCode.weakPassword.rawValue {
                errorMessage = GlobalError.weakPassword.errorDescription
                UnifiedLogger.log("Sign up failed: \(GlobalError.weakPassword.errorDescription ?? "")", level: .error)
                throw GlobalError.weakPassword
            } else {
                let mappedError = GlobalError.unknown(err.localizedDescription)
                errorMessage = mappedError.errorDescription
                UnifiedLogger.log("Sign up failed: \(mappedError.errorDescription ?? "")", level: .error)
                throw mappedError
            }
        }
    }

    /// Signs out the current user.
    func signOut() async throws {
        UnifiedLogger.log("Attempting sign out via AuthViewModel.", level: .info)
        do {
            try Auth.auth().signOut()
            UnifiedLogger.log("User signed out successfully.", level: .info)
        } catch let err as NSError {
            isLoading = false
            let mappedError = GlobalError.unknown(err.localizedDescription)
            errorMessage = mappedError.errorDescription
            UnifiedLogger.log("Sign out failed: \(mappedError.errorDescription ?? "")", level: .error)
            throw mappedError
        }
    }
}

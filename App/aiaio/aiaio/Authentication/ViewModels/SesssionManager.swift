@preconcurrency import Foundation
import FirebaseAuth

@MainActor
final class SessionManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published private(set) var currentUser: User?

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        UnifiedLogger.info("Initializing SessionManager and setting up auth state listener.", context: "Auth")
        // Listen for Firebase authentication state changes.
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isSignedIn = (user != nil)
                if let user = user {
                    UnifiedLogger.info("User \(user.uid) signed in (auth listener).", context: "Auth")
                } else {
                    UnifiedLogger.info("User signed out (auth listener).", context: "Auth")
                }
            }
        }
    }

    deinit {
        UnifiedLogger.info("SessionManager being deallocated", context: "Auth")
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    /// Signs out the current user.
    /// - Throws: GlobalError if sign out fails
    func signOut() {
        UnifiedLogger.info("Attempting sign out.", context: "Auth")
        do {
            try Auth.auth().signOut()
            UnifiedLogger.info("Sign out succeeded.", context: "Auth")
        } catch let error {
            let mappedError = mapFirebaseError(error)
            UnifiedLogger.error("Sign out failed: \(mappedError.errorDescription ?? "")", context: "Auth")
        }
    }
}

@preconcurrency import Foundation
import FirebaseAuth

@MainActor
final class SessionManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published private(set) var currentUser: User?  // Removed redundant initialization

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        UnifiedLogger.log("Initializing SessionManager and setting up auth state listener.", level: .info)
        // Listen for Firebase authentication state changes.
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isSignedIn = (user != nil)
                if let user = user {
                    UnifiedLogger.log("User \(user.uid) signed in (auth listener).", level: .info)
                } else {
                    UnifiedLogger.log("User signed out (auth listener).", level: .info)
                }
            }
        }
    }

    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    /// Signs out the current user.
    func signOut() {
        UnifiedLogger.log("Attempting sign out.", level: .info)
        do {
            try Auth.auth().signOut()
            UnifiedLogger.log("Sign out succeeded.", level: .info)
        } catch {
            UnifiedLogger.log("Sign out failed: \(error.localizedDescription)", level: .error)
        }
    }
}

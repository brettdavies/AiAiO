@preconcurrency import FirebaseAuth  // Add preconcurrency to handle non-Sendable types
import FirebaseCore
import FirebaseFirestore
import Foundation

/// A service that handles all authentication-related operations
@globalActor
final actor AuthService: @unchecked Sendable {
    // MARK: - Properties
    static let shared = AuthService()

    // Firebase Auth is thread-safe, so we can make this nonisolated
    nonisolated private let auth = Auth.auth()
    private let db = Firestore.firestore()  // Firestore is thread-safe

    /// The current user's ID, if authenticated
    nonisolated var currentUserId: String? {
        auth.currentUser?.uid
    }

    /// Whether a user is currently signed in
    nonisolated var isAuthenticated: Bool {
        auth.currentUser != nil
    }

    /// Gets the current Firebase user
    private func getCurrentFirebaseUser() async throws -> User {
        guard let user = auth.currentUser else {
            throw GlobalError.auth(
                AuthError.userNotFound(
                    NSLocalizedString("auth.error.user_not_found", comment: "")))
        }
        try await user.reload()  // Ensure we have the latest user data
        return user
    }

    /// Signs out the current user and cleans up any resources
    func signOut() async throws {
        do {
            // Get current user before signing out to clean up resources
            if let userId = currentUserId {
                // Update user's last sign out time
                let ref = db.collection("users").document(userId)
                try await ref.updateData([
                    "lastSignOut": Date()
                ])
            }

            // Sign out from Firebase
            try auth.signOut()

            await LogManager.shared.log(
                level: .info,
                message: "User signed out successfully",
                metadata: ["category": LogCategory.auth.rawValue]
            )
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Sends a password reset email to the specified email address
    func sendPasswordReset(to email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Resends the email verification to the current user
    func resendEmailVerification() async throws {
        let user = try await getCurrentFirebaseUser()
        try await user.sendEmailVerification()
    }

    /// Refreshes the current user's email verification status
    func refreshEmailVerificationStatus() async throws -> FirestoreUser {
        let user = try await getCurrentFirebaseUser()

        // Update Firestore with the new verification status
        let ref = db.collection("users").document(user.uid)
        try await ref.updateData([
            "isEmailVerified": user.isEmailVerified,
            "lastVerificationCheck": Date(),
        ])

        return try await getCurrentUser()
    }

    /// Updates the current user's profile information
    func updateProfile(displayName: String? = nil, photoURL: URL? = nil) async throws {
        let user = try await getCurrentFirebaseUser()

        do {
            // Update Firebase Auth profile
            let changeRequest = user.createProfileChangeRequest()
            if let displayName = displayName {
                changeRequest.displayName = displayName
            }
            if let photoURL = photoURL {
                changeRequest.photoURL = photoURL
            }
            try await changeRequest.commitChanges()

            // Update Firestore
            let ref = db.collection("users").document(user.uid)
            try await ref.updateData([
                "displayName": displayName as Any,
                "photoURL": photoURL?.absoluteString as Any,
                "lastUpdated": Date(),
            ])
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Fetches the current user's data from Firestore
    func getCurrentUser() async throws -> FirestoreUser {
        let user = try await getCurrentFirebaseUser()

        do {
            let snapshot = try await db.collection("users").document(user.uid).getDocument()
            return try FirestoreUser.from(snapshot)
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Signs up a new user with email and password
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    ///   - confirmPassword: Password confirmation
    /// - Returns: The created FirestoreUser
    func signUp(email: String, password: String, confirmPassword: String) async throws
        -> FirestoreUser
    {
        try GlobalValidator.validateSignUp(
            email: email, password: password, confirmPassword: confirmPassword)

        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            try await result.user.sendEmailVerification()

            let user = FirestoreUser(
                id: result.user.uid,
                email: email,
                createdAt: Date(),
                isEmailVerified: false,
                displayName: nil,
                photoURL: nil
            )

            let ref = db.collection("users").document(user.id)
            try await ref.setData(user.asDictionary)

            return user
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Signs in an existing user with email and password
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    /// - Returns: The signed-in FirestoreUser
    func signIn(email: String, password: String) async throws -> FirestoreUser {
        try GlobalValidator.validateSignIn(email: email, password: password)

        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            let snapshot = try await db.collection("users").document(result.user.uid).getDocument()
            return try FirestoreUser.from(snapshot)
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }
}

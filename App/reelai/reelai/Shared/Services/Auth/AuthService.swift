import FirebaseAuth
import FirebaseFirestore
import Foundation
import GoogleSignIn
import GoogleSignInSwift

/// A service that handles all authentication-related operations
@globalActor
final actor AuthService {
    // MARK: - Properties
    static let shared = AuthService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    /// The current user's ID, if authenticated
    nonisolated var currentUserId: String? {
        auth.currentUser?.uid
    }

    /// Whether a user is currently signed in
    nonisolated var isAuthenticated: Bool {
        auth.currentUser != nil
    }

    // MARK: - Authentication Methods

    /// Signs up a new user with email and password
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    ///   - confirmPassword: Password confirmation
    /// - Returns: The created FirestoreUser
    func signUp(email: String, password: String, confirmPassword: String) async throws
        -> FirestoreUser
    {
        // Validate input using GlobalValidator
        try GlobalValidator.validateSignUp(
            email: email, password: password, confirmPassword: confirmPassword)

        do {
            // Create the user
            let result = try await auth.createUser(withEmail: email, password: password)

            // Send verification email
            try await result.user.sendEmailVerification()

            // Create Firestore user
            let user = FirestoreUser(
                id: result.user.uid,
                email: email,
                createdAt: Date(),
                isEmailVerified: false,
                displayName: nil,
                photoURL: nil
            )

            // Save to Firestore
            if let ref = user.documentReference {
                try await ref.setData(user.asDictionary)
            }

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
        // Validate input using GlobalValidator
        try GlobalValidator.validateSignIn(email: email, password: password)

        do {
            let result = try await auth.signIn(withEmail: email, password: password)

            // Fetch user data from Firestore
            let snapshot = try await db.collection("users").document(result.user.uid).getDocument()
            return try FirestoreUser.from(snapshot)
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Signs out the current user
    func signOut() async throws {
        do {
            try auth.signOut()
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Sends a password reset email to the specified email address
    /// - Parameter email: The email address to send the reset link to
    func sendPasswordReset(to email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Updates the current user's profile information
    /// - Parameters:
    ///   - displayName: Optional new display name
    ///   - photoURL: Optional new photo URL
    func updateProfile(displayName: String? = nil, photoURL: URL? = nil) async throws {
        guard let user = auth.currentUser else {
            throw GlobalError.auth(
                AuthError.userNotFound(
                    NSLocalizedString("auth.error.user_not_found", comment: "")))
        }

        do {
            let changeRequest = user.createProfileChangeRequest()
            if let displayName = displayName {
                changeRequest.displayName = displayName
            }
            if let photoURL = photoURL {
                changeRequest.photoURL = photoURL
            }
            try await changeRequest.commitChanges()

            // Update Firestore
            if let ref = db.collection("users").document(user.uid) {
                try await ref.updateData([
                    "displayName": displayName as Any,
                    "photoURL": photoURL?.absoluteString as Any,
                ])
            }
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Fetches the current user's data from Firestore
    /// - Returns: The current FirestoreUser
    func getCurrentUser() async throws -> FirestoreUser {
        guard let userId = currentUserId else {
            throw GlobalError.auth(
                AuthError.userNotFound(
                    NSLocalizedString("auth.error.user_not_found", comment: "")))
        }

        do {
            let snapshot = try await db.collection("users").document(userId).getDocument()
            return try FirestoreUser.from(snapshot)
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Signs in a user with Google
    func signInWithGoogle() async throws -> FirestoreUser {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GlobalError.auth(
                AuthError.unknown(NSLocalizedString("auth.error.google_config", comment: "")))
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Get the top view controller
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first?.rootViewController
        else {
            throw GlobalError.auth(
                AuthError.unknown(NSLocalizedString("auth.error.no_root_view", comment: "")))
        }

        // Perform Google Sign In
        let result = try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) {
                signInResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let signInResult = signInResult else {
                    continuation.resume(
                        throwing: GlobalError.auth(
                            AuthError.unknown(
                                NSLocalizedString("auth.error.google_sign_in", comment: ""))))
                    return
                }

                continuation.resume(returning: signInResult)
            }
        }

        guard let idToken = result.user.idToken?.tokenString else {
            throw GlobalError.auth(
                AuthError.unknown(NSLocalizedString("auth.error.google_token", comment: "")))
        }

        // Create Firebase credential
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        // Sign in to Firebase
        let authResult = try await auth.signIn(with: credential)

        // Create or update Firestore user
        let user = FirestoreUser(
            id: authResult.user.uid,
            email: authResult.user.email ?? "",
            createdAt: Date(),
            isEmailVerified: authResult.user.isEmailVerified,
            displayName: authResult.user.displayName,
            photoURL: authResult.user.photoURL
        )

        // Validate user data
        try await user.validate()

        // Save to Firestore
        if let ref = user.documentReference {
            try await ref.setData(user.asDictionary, merge: true)
        }

        return user
    }

    /// Resends the email verification to the current user
    /// - Throws: AuthError if the user is not found or if sending fails
    func resendEmailVerification() async throws {
        guard let user = auth.currentUser else {
            throw GlobalError.auth(
                AuthError.userNotFound(
                    NSLocalizedString("auth.error.user_not_found", comment: "")))
        }

        do {
            try await user.sendEmailVerification()
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }

    /// Refreshes the current user's email verification status
    /// - Returns: The updated FirestoreUser
    func refreshEmailVerificationStatus() async throws -> FirestoreUser {
        guard let user = auth.currentUser else {
            throw GlobalError.auth(
                AuthError.userNotFound(
                    NSLocalizedString("auth.error.user_not_found", comment: "")))
        }

        do {
            // Reload the user to get the latest verification status
            try await user.reload()

            // Update Firestore with the new verification status
            if let ref = db.collection("users").document(user.uid) {
                try await ref.updateData([
                    "isEmailVerified": user.isEmailVerified
                ])
            }

            return try await getCurrentUser()
        } catch {
            throw GlobalError.auth(AuthError.from(error))
        }
    }
}

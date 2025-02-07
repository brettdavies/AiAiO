@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore
import Foundation

/// Protocol defining the authentication service interface
protocol AuthProviding {
    /// The current user's ID, if authenticated
    var currentUserId: String? { get }

    /// Whether a user is currently signed in
    var isAuthenticated: Bool { get }

    /// Signs up a new user with email and password
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    ///   - confirmPassword: Password confirmation
    /// - Returns: The created FirestoreUser
    func signUp(email: String, password: String, confirmPassword: String) async throws
        -> FirestoreUser

    /// Signs in an existing user with email and password
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password
    /// - Returns: The signed-in FirestoreUser
    func signIn(email: String, password: String) async throws -> FirestoreUser

    /// Signs out the current user
    func signOut() async throws

    /// Sends a password reset email to the specified email address
    /// - Parameter email: The email address to send the reset link to
    func sendPasswordReset(to email: String) async throws

    /// Resends the email verification to the current user
    func resendEmailVerification() async throws

    /// Refreshes the current user's email verification status
    /// - Returns: The updated FirestoreUser
    func refreshEmailVerificationStatus() async throws -> FirestoreUser

    /// Updates the current user's profile information
    /// - Parameters:
    ///   - displayName: Optional new display name
    ///   - photoURL: Optional new photo URL
    func updateProfile(displayName: String?, photoURL: URL?) async throws

    /// Gets the current authenticated user
    /// - Returns: The current FirestoreUser
    func getCurrentUser() async throws -> FirestoreUser
}

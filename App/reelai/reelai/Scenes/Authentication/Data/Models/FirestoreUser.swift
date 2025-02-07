@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore
import Foundation

/// A Sendable user model that represents a user in Firestore
struct FirestoreUser: Codable, Sendable {
    /// The unique identifier for the user
    let id: String

    /// The user's email address
    let email: String

    /// The timestamp when the user was created
    let createdAt: Date

    /// Whether the user's email has been verified
    let isEmailVerified: Bool

    /// Optional display name for the user
    let displayName: String?

    /// Optional photo URL for the user's profile picture
    let photoURL: URL?

    // Cache Firestore instance since it's thread-safe
    nonisolated private static let db = Firestore.firestore()

    /// Asynchronously gets the Firestore document reference for this user
    func getDocumentReference() async throws -> DocumentReference {
        guard !id.isEmpty else {
            throw FirebaseError.invalidConfiguration("User ID cannot be empty")
        }
        return Self.db.collection("users").document(id)
    }

    /// Dictionary representation for Firestore
    var asDictionary: [String: Any] {
        [
            "id": id,
            "email": email,
            "createdAt": createdAt,
            "isEmailVerified": isEmailVerified,
            "displayName": displayName as Any,
            "photoURL": photoURL?.absoluteString as Any,
        ]
    }

    /// Creates a FirestoreUser from a Firestore document
    static func from(_ document: DocumentSnapshot) throws -> FirestoreUser {
        guard let data = document.data() else {
            throw FirebaseError.invalidConfiguration("Invalid user data in Firestore")
        }

        let email = data["email"] as? String ?? ""
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let isEmailVerified = data["isEmailVerified"] as? Bool ?? false
        let displayName = data["displayName"] as? String
        let photoURL = (data["photoURL"] as? String).flatMap { URL(string: $0) }

        return FirestoreUser(
            id: document.documentID,
            email: email,
            createdAt: createdAt,
            isEmailVerified: isEmailVerified,
            displayName: displayName,
            photoURL: photoURL
        )
    }
}

// MARK: - Validation
extension FirestoreUser {
    /// Validates the user model according to business rules
    func validate() async throws {
        // Email validation using GlobalValidator
        try GlobalValidator.validateEmail(email)

        // Creation date validation
        try GlobalValidator.validateCreationDate(createdAt)
    }
}

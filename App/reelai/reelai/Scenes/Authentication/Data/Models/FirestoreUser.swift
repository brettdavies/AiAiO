import FirebaseFirestore
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

    /// Firestore document reference
    var documentReference: DocumentReference? {
        guard !id.isEmpty else { return nil }
        return Firestore.firestore().collection("users").document(id)
    }
}

// MARK: - Validation
extension FirestoreUser {
    /// Validates the user model according to business rules
    func validate() async throws {
        // Email validation using GlobalValidator
        try GlobalValidator.validateEmail(email)

        // Display name validation (if provided)
        if let displayName = displayName {
            try GlobalValidator.validateDisplayName(displayName)
        }

        // Photo URL validation (if provided)
        if let photoURL = photoURL {
            try GlobalValidator.validatePhotoURL(photoURL)
        }

        // Creation date validation
        try GlobalValidator.validateCreationDate(createdAt)
    }
}

// MARK: - Firestore Conversion
extension FirestoreUser {
    /// Creates a dictionary representation for Firestore
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
            throw AuthError.invalidUserData(NSLocalizedString("auth.error.generic", comment: ""))
        }

        return try FirestoreUser(
            id: document.documentID,
            email: data["email"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            isEmailVerified: data["isEmailVerified"] as? Bool ?? false,
            displayName: data["displayName"] as? String,
            photoURL: (data["photoURL"] as? String).flatMap { URL(string: $0) }
        )
    }
}

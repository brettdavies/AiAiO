import FirebaseAuth
import Foundation

/// Authentication-related errors
enum AuthError: LocalizedError {
    case invalidEmail(String)
    case invalidPassword(String)
    case passwordMismatch(String)
    case userNotFound(String)
    case invalidCredentials(String)
    case emailAlreadyInUse(String)
    case weakPassword(String)
    case networkError(String)
    case configurationError(String)
    case unknown(String)
    case invalidDate(String)
    case wrongPassword(String)
    case requiresRecentLogin(String)
    case invalidUserData(String)
    case invalidDisplayName(String)
    case invalidPhotoURL(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail(let message):
            return NSLocalizedString(message, comment: "Invalid email error")
        case .invalidPassword(let message):
            return NSLocalizedString(message, comment: "Invalid password error")
        case .passwordMismatch(let message):
            return NSLocalizedString(message, comment: "Password mismatch error")
        case .emailAlreadyInUse(let message):
            return NSLocalizedString(message, comment: "Email already in use error")
        case .userNotFound(let message):
            return NSLocalizedString(message, comment: "User not found error")
        case .invalidCredentials(let message):
            return NSLocalizedString(message, comment: "Invalid credentials error")
        case .weakPassword(let message):
            return NSLocalizedString(message, comment: "Weak password error")
        case .networkError(let message):
            return NSLocalizedString(message, comment: "Network error")
        case .configurationError(let message):
            return NSLocalizedString(message, comment: "Configuration error")
        case .unknown(let message):
            return NSLocalizedString(message, comment: "Unknown error")
        case .invalidDate(let message):
            return NSLocalizedString(message, comment: "Invalid date error")
        case .wrongPassword(let message):
            return NSLocalizedString(message, comment: "Wrong password error")
        case .requiresRecentLogin(let message):
            return NSLocalizedString(message, comment: "Requires recent login error")
        case .invalidUserData(let message):
            return NSLocalizedString(message, comment: "Invalid user data error")
        case .invalidDisplayName(let message):
            return NSLocalizedString(message, comment: "Invalid display name error")
        case .invalidPhotoURL(let message):
            return NSLocalizedString(message, comment: "Invalid photo URL error")
        }
    }

    static func from(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }

        let nsError = error as NSError
        switch nsError.code {
        case 17020:
            return .networkError(
                NSLocalizedString("auth.error.network", comment: ""))
        case 17008:
            return .invalidEmail(
                NSLocalizedString("auth.error.invalid_email", comment: ""))
        case 17009:
            return .invalidPassword(
                NSLocalizedString("auth.error.invalid_password", comment: ""))
        case 17011:
            return .userNotFound(
                NSLocalizedString("auth.error.user_not_found", comment: ""))
        case 17007:
            return .emailAlreadyInUse(
                NSLocalizedString("auth.error.email_in_use", comment: ""))
        case 17026:
            return .weakPassword(
                NSLocalizedString("auth.error.weak_password", comment: ""))
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

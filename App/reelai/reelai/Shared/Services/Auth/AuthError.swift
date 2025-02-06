import FirebaseAuth
import Foundation

/// Authentication-related errors that can occur in the app
enum AuthError: LocalizedError, Sendable {
    // MARK: - Validation Errors
    case invalidEmail(String)
    case invalidPassword(String)
    case passwordMismatch(String)
    case invalidDisplayName
    case invalidPhotoURL
    case invalidUserData(String)

    // MARK: - Authentication Errors
    case emailAlreadyInUse(String)
    case userNotFound(String)
    case wrongPassword(String)
    case requiresRecentLogin(String)
    case networkError(String)
    case mfaRequired(String)
    case unknown(String)

    // MARK: - LocalizedError Conformance
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return NSLocalizedString("auth.error.invalid.email", comment: "")
        case .invalidPassword:
            return NSLocalizedString("auth.error.weak.password", comment: "")
        case .passwordMismatch:
            return NSLocalizedString("auth.validation.password.mismatch", comment: "")
        case .emailAlreadyInUse:
            return NSLocalizedString("auth.error.email.in_use", comment: "")
        case .userNotFound:
            return NSLocalizedString("auth.error.user_not_found", comment: "")
        case .wrongPassword:
            return NSLocalizedString("auth.error.invalid_credentials", comment: "")
        case .requiresRecentLogin:
            return NSLocalizedString("auth.error.requires_recent_login", comment: "")
        case .networkError:
            return NSLocalizedString("auth.error.network", comment: "")
        case .mfaRequired:
            return NSLocalizedString("auth.mfa.verify.title", comment: "")
        case .unknown:
            return NSLocalizedString("auth.error.generic", comment: "")
        case .invalidUserData:
            return NSLocalizedString("auth.error.invalid_user_data", comment: "")
        case .invalidDisplayName:
            return NSLocalizedString("auth.error.invalid_display_name", comment: "")
        case .invalidPhotoURL:
            return NSLocalizedString("auth.error.invalid_photo_url", comment: "")
        }
    }

    // MARK: - Firebase Error Mapping
    static func from(_ error: Error) -> AuthError {
        let nsError = error as NSError

        switch nsError.code {
        case 17007:  // FIRAuthErrorCodeEmailAlreadyInUse
            return .emailAlreadyInUse(NSLocalizedString("auth.error.email_in_use", comment: ""))
        case 17011:  // FIRAuthErrorCodeUserNotFound
            return .userNotFound(NSLocalizedString("auth.error.user_not_found", comment: ""))
        case 17009:  // FIRAuthErrorCodeWrongPassword
            return .wrongPassword(NSLocalizedString("auth.error.invalid_credentials", comment: ""))
        case 17014:  // FIRAuthErrorCodeRequiresRecentLogin
            return .requiresRecentLogin(
                NSLocalizedString("auth.error.requires_recent_login", comment: ""))
        case -1009:  // NSURLErrorNotConnectedToInternet
            return .networkError(NSLocalizedString("auth.error.network", comment: ""))
        case 17055:  // FIRAuthErrorCodeSecondFactorRequired
            return .mfaRequired(NSLocalizedString("auth.mfa.verify.title", comment: ""))
        default:
            return .unknown(NSLocalizedString("auth.error.generic", comment: ""))
        }
    }
}

import Foundation

/// Global error type for the application
enum GlobalError: LocalizedError {
    // Authentication errors
    case invalidEmail
    case weakPassword
    case invalidCredentials
    case userNotFound

    // Network errors
    case networkFailure
    case serverError
    case timeoutError

    // Video errors
    case videoTooLarge
    case unsupportedFormat
    case uploadFailed

    // Permission errors
    case insufficientPermissions
    case notAuthenticated

    // Generic errors
    case unknown(String)

    var errorDescription: String? {
        switch self {
        // Authentication
        case .invalidEmail:
            return "The email address is invalid"
        case .weakPassword:
            return "The password is too weak"
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "No user found with this email"

        // Network
        case .networkFailure:
            return "Network connection error"
        case .serverError:
            return "Server error occurred"
        case .timeoutError:
            return "Request timed out"

        // Video
        case .videoTooLarge:
            return "Video file exceeds maximum size limit"
        case .unsupportedFormat:
            return "Unsupported video format"
        case .uploadFailed:
            return "Failed to upload video"

        // Permissions
        case .insufficientPermissions:
            return "You don't have permission to perform this action"
        case .notAuthenticated:
            return "Please sign in to continue"

        // Generic
        case .unknown(let message):
            return message
        }
    }

    var failureReason: String? {
        switch self {
        case .invalidEmail:
            return "The email format is incorrect"
        case .weakPassword:
            return "Password must meet minimum requirements"
        case .videoTooLarge:
            return "Maximum file size is 100MB"
        case .unknown:
            return nil
        default:
            return errorDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkFailure:
            return "Check your internet connection and try again"
        case .weakPassword:
            return "Use at least 8 characters with numbers and special characters"
        case .videoTooLarge:
            return "Try uploading a smaller video or compress the current one"
        case .notAuthenticated:
            return "Sign in to your account to continue"
        default:
            return nil
        }
    }
}

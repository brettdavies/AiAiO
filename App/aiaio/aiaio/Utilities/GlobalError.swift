import Foundation

/// A global error type that provides consistent error handling across the app
enum GlobalError: LocalizedError {
    // MARK: - Cases

    /// Authentication related errors
    case invalidEmail
    case weakPassword
    case authenticationFailed

    /// Network related errors
    case networkFailure
    case serverError
    case timeoutError

    /// Data related errors
    case invalidData
    case decodingError
    case encodingError

    /// Video related errors
    case videoTooLarge
    case invalidVideoFormat
    case uploadFailed

    /// Generic errors
    case unknown(String)
    case notImplemented

    // MARK: - LocalizedError Conformance

    var errorDescription: String? {
        switch self {
        // Authentication errors
        case .invalidEmail:
            return "The email address is invalid"
        case .weakPassword:
            return "The password is too weak"
        case .authenticationFailed:
            return "Authentication failed"

        // Network errors
        case .networkFailure:
            return "Network connection failed"
        case .serverError:
            return "Server error occurred"
        case .timeoutError:
            return "Request timed out"

        // Data errors
        case .invalidData:
            return "Invalid data received"
        case .decodingError:
            return "Failed to decode data"
        case .encodingError:
            return "Failed to encode data"

        // Video errors
        case .videoTooLarge:
            return "Video file exceeds maximum size limit"
        case .invalidVideoFormat:
            return "Unsupported video format"
        case .uploadFailed:
            return "Failed to upload video"

        // Generic errors
        case .unknown(let message):
            return "Unknown error: \(message)"
        case .notImplemented:
            return "This feature is not implemented yet"
        }
    }

    var failureReason: String? {
        switch self {
        case .unknown(let detail):
            return detail
        default:
            return nil
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkFailure:
            return "Please check your internet connection and try again"
        case .weakPassword:
            return "Please use a stronger password with at least 8 characters"
        case .videoTooLarge:
            return "Please select a video under 100MB"
        default:
            return nil
        }
    }
}

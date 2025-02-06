import FirebaseAuth
import Foundation

/// A top-level error type that encompasses all possible errors in the app
enum GlobalError: LocalizedError, Sendable {
    case auth(AuthError)
    case validation(ValidationError)
    case unknown(String)

    /// Validation-specific errors
    enum ValidationError: LocalizedError, Sendable {
        case invalidInput(String)
        case missingField(String)
        case invalidFormat(String)

        var errorDescription: String? {
            switch self {
            case .invalidInput(let field):
                return String(
                    format: NSLocalizedString("error.validation.invalid_input", comment: ""), field)
            case .missingField(let field):
                return String(
                    format: NSLocalizedString("error.validation.missing_field", comment: ""), field)
            case .invalidFormat(let field):
                return String(
                    format: NSLocalizedString("error.validation.invalid_format", comment: ""), field
                )
            }
        }
    }

    // MARK: - LocalizedError Conformance
    var errorDescription: String? {
        switch self {
        case .auth(let error):
            return error.errorDescription
        case .validation(let error):
            return error.errorDescription
        case .unknown(let message):
            return message
        }
    }

    // MARK: - Error Mapping

    /// Maps any error to a GlobalError
    static func from(_ error: Error) -> GlobalError {
        switch error {
        case let authError as AuthError:
            return .auth(authError)
        case let globalError as GlobalError:
            return globalError
        case let nsError as NSError:
            return .unknown(nsError.localizedDescription)
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

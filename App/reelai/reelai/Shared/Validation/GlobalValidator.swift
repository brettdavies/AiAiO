import FirebaseAuth
import Foundation

/// A centralized validator for all authentication-related validations
enum GlobalValidator {
    // MARK: - Email Validation

    /// Validates an email address
    /// - Parameter email: The email address to validate
    /// - Throws: AuthError.invalidEmail if validation fails
    static func validateEmail(_ email: String) throws {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        guard !email.isEmpty, emailPredicate.evaluate(with: email) else {
            throw AuthError.invalidEmail(
                NSLocalizedString("auth.validation.email.invalid", comment: ""))
        }
    }

    // MARK: - Password Validation

    /// Validates a password
    /// - Parameter password: The password to validate
    /// - Throws: AuthError.invalidPassword if validation fails
    static func validatePassword(_ password: String) throws {
        guard password.count >= 6 else {
            throw AuthError.invalidPassword(
                NSLocalizedString("auth.validation.password.too_short", comment: ""))
        }

        // Check for at least one uppercase letter
        guard password.contains(where: { $0.isUppercase }) else {
            throw AuthError.invalidPassword(
                NSLocalizedString("auth.validation.password.requirements", comment: ""))
        }

        // Check for at least one number
        guard password.contains(where: { $0.isNumber }) else {
            throw AuthError.invalidPassword(
                NSLocalizedString("auth.validation.password.requirements", comment: ""))
        }

        // Check for at least one special character
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        guard password.unicodeScalars.contains(where: { specialCharacters.contains($0) }) else {
            throw AuthError.invalidPassword(
                NSLocalizedString("auth.validation.password.requirements", comment: ""))
        }
    }

    /// Validates that two passwords match
    /// - Parameters:
    ///   - password: The original password
    ///   - confirmPassword: The confirmation password
    /// - Throws: AuthError.passwordMismatch if passwords don't match
    static func validatePasswordsMatch(_ password: String, _ confirmPassword: String) throws {
        guard password == confirmPassword else {
            throw AuthError.passwordMismatch(
                NSLocalizedString("auth.validation.password.mismatch", comment: ""))
        }
    }

    // MARK: - Sign Up Validation

    /// Validates all sign-up input fields
    /// - Parameters:
    ///   - email: The email address
    ///   - password: The password
    ///   - confirmPassword: The confirmation password
    /// - Throws: Various AuthError types depending on validation failure
    static func validateSignUp(email: String, password: String, confirmPassword: String) throws {
        try validateEmail(email)
        try validatePassword(password)
        try validatePasswordsMatch(password, confirmPassword)
    }

    // MARK: - Sign In Validation

    /// Validates sign-in input fields
    /// - Parameters:
    ///   - email: The email address
    ///   - password: The password
    /// - Throws: Various AuthError types depending on validation failure
    static func validateSignIn(email: String, password: String) throws {
        try validateEmail(email)
        guard !password.isEmpty else {
            throw AuthError.invalidPassword(
                NSLocalizedString("auth.validation.password.too_short", comment: ""))
        }
    }

    // MARK: - Quick Form Validation

    /// Quick validation for sign-up form (used for UI feedback)
    /// - Parameters:
    ///   - email: The email address
    ///   - password: The password
    ///   - confirmPassword: The confirmation password
    /// - Returns: Whether the form is valid
    static func isSignUpFormValid(email: String, password: String, confirmPassword: String) -> Bool
    {
        guard !email.isEmpty, email.contains("@"),
            !password.isEmpty, password.count >= 6,
            password == confirmPassword
        else {
            return false
        }
        return true
    }

    /// Quick validation for sign-in form (used for UI feedback)
    /// - Parameters:
    ///   - email: The email address
    ///   - password: The password
    /// - Returns: Whether the form is valid
    static func isSignInFormValid(email: String, password: String) -> Bool {
        guard !email.isEmpty, email.contains("@"),
            !password.isEmpty
        else {
            return false
        }
        return true
    }

    // MARK: - Display Name Validation

    /// Validates a display name
    /// - Parameter displayName: The display name to validate
    /// - Throws: AuthError.invalidDisplayName if validation fails
    static func validateDisplayName(_ displayName: String) throws {
        guard !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthError.invalidDisplayName(
                NSLocalizedString("auth.validation.displayname.empty", comment: ""))
        }

        guard displayName.count <= 50 else {
            throw AuthError.invalidDisplayName(
                NSLocalizedString("auth.validation.displayname.too_long", comment: ""))
        }
    }

    // MARK: - URL Validation

    /// Validates a photo URL
    /// - Parameter url: The URL to validate
    /// - Throws: AuthError.invalidPhotoURL if validation fails
    static func validatePhotoURL(_ url: URL) throws {
        guard url.scheme == "https" else {
            throw AuthError.invalidPhotoURL(
                NSLocalizedString("auth.validation.photo.not_secure", comment: ""))
        }

        guard let host = url.host, !host.isEmpty else {
            throw AuthError.invalidPhotoURL(
                NSLocalizedString("auth.validation.photo.invalid", comment: ""))
        }
    }

    // MARK: - Date Validation

    /// Validates a creation date
    /// - Parameter date: The date to validate
    /// - Throws: AuthError.invalidUserData if validation fails
    static func validateCreationDate(_ date: Date) throws {
        guard date <= Date() else {
            throw AuthError.invalidUserData(
                NSLocalizedString("auth.validation.date.future", comment: ""))
        }
    }
}

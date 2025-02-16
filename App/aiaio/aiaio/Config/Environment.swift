import Foundation

/// Environment configuration for the app
enum Environment {
    /// The current environment the app is running in
    static var current: EnvironmentType {
        #if DEBUG
            // Local development
            UnifiedLogger.info("Running in local development environment", context: "App")
            return .development
        #elseif STAGING
            // Remote staging
            UnifiedLogger.info("Running in hosted staging environment", context: "App")
            return .staging
        #else
            UnifiedLogger.info("Running in production environment", context: "App")
            return .production
        #endif
    }

    /// Available environment types
    enum EnvironmentType {
        case development
        case staging
        case production

        /// Firebase project ID for the current environment
        var firebaseProjectId: String {
            switch self {
            case .development, .staging:
                return "aiaio-dev"
            case .production:
                return "aiaio-prod"
            }
        }

        /// Whether to use Firebase local emulator
        var useFirebaseEmulator: Bool {
            switch self {
            case .development:
                return true
            case .staging:
                return false
            case .production:
                return false
            }
        }
    }
}

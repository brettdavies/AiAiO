import FirebaseCore
import Foundation

/// Environment configuration for Firebase and logging destinations
@globalActor
final actor FirebaseEnvironment {
    // MARK: - Singleton
    static let shared = FirebaseEnvironment()

    // MARK: - Environment Types
    enum Environment: String {
        case development
        case production
    }

    // MARK: - Logging Destination
    enum LoggingDestination: String {
        case app = "App"  // Client-side logging
        case firebase = "Firebase"  // Server-side logging
        case both = "Both"  // Log to both destinations
    }

    // MARK: - Configuration
    struct Config {
        let projectID: String
        let apiKey: String
        let authDomain: String
        let loggingDestination: LoggingDestination
        let loggingLevel: LogLevel
        let useEmulator: Bool

        var firebaseOptions: FirebaseOptions {
            let options = FirebaseOptions(
                googleAppID: projectID,
                gcmSenderID: ""  // Not using FCM yet
            )
            options.apiKey = apiKey
            options.projectID = projectID
            options.authDomain = authDomain
            return options
        }
    }

    // MARK: - Properties
    private var currentEnvironment: Environment = .development
    private var isInitialized = false

    // MARK: - Configuration Methods
    func config(for environment: Environment) async -> Config {
        switch environment {
        case .development:
            return Config(
                projectID: ProcessInfo.processInfo.environment["FIREBASE_PROJECT_ID"]
                    ?? "dev-reelai",
                apiKey: ProcessInfo.processInfo.environment["FIREBASE_API_KEY"] ?? "",
                authDomain:
                    "\(ProcessInfo.processInfo.environment["FIREBASE_PROJECT_ID"] ?? "dev-reelai").firebaseapp.com",
                loggingDestination: .both,
                loggingLevel: .debug,
                useEmulator: true
            )

        case .production:
            return Config(
                projectID: ProcessInfo.processInfo.environment["FIREBASE_PROJECT_ID"] ?? "",
                apiKey: ProcessInfo.processInfo.environment["FIREBASE_API_KEY"] ?? "",
                authDomain:
                    "\(ProcessInfo.processInfo.environment["FIREBASE_PROJECT_ID"] ?? "").firebaseapp.com",
                loggingDestination: .firebase,
                loggingLevel: .warning,
                useEmulator: false
            )
        }
    }

    // MARK: - Initialization
    func initialize(environment: Environment) async throws {
        guard !isInitialized else { return }

        currentEnvironment = environment
        let config = await config(for: environment)

        try await FirebaseApp.configure(options: config.firebaseOptions)

        if config.useEmulator {
            try await useEmulators()
        }

        isInitialized = true
    }

    // MARK: - Emulator Configuration
    private func useEmulators() async throws {
        Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        let db = Firestore.firestore()
        db.settings = FirestoreSettings()
        db.settings.host = "localhost:8080"
        db.settings.isPersistenceEnabled = true
        db.settings.isSSLEnabled = false
        Storage.storage().useEmulator(withHost: "localhost", port: 9199)
        Functions.functions().useEmulator(withHost: "localhost", port: 5001)
        }
    }

// MARK: - Logging Level
enum LogLevel: String {
    case debug
    case info
    case warning
    case error
}

struct FirebaseConfig {
    let projectID: String
    let apiKey: String
    let authDomain: String
    let storageBucket: String
    let googleAppID: String
    let gcmSenderID: String
    let bundleID: String
    let databaseURL: String

    var firebaseOptions: FirebaseOptions {
        let options = FirebaseOptions(
            googleAppID: googleAppID,
            gcmSenderID: gcmSenderID
        )
        options.projectID = projectID
        options.apiKey = apiKey
        options.storageBucket = storageBucket
        options.bundleID = bundleID
        options.databaseURL = databaseURL
        return options
    }
}

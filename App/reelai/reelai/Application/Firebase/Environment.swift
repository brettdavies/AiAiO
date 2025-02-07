import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage
import Foundation

/// Environment configuration for Firebase
@globalActor
public final actor FirebaseEnvironment {
    // MARK: - Singleton
    public static let shared = FirebaseEnvironment()

    // MARK: - Environment Types
    public enum Environment: String, CaseIterable, Sendable {
        case development
        case production
    }

    // MARK: - Configuration
    struct Config: Sendable {
        let projectID: String
        let apiKey: String

        let loggingLevel: LogLevel
        let useEmulator: Bool
        let storageBucket: String
        let googleAppID: String
        let gcmSenderID: String
        let measurementId: String?

        var firebaseOptions: FirebaseOptions {
            let options = FirebaseOptions(
                googleAppID: googleAppID,
                gcmSenderID: gcmSenderID
            )
            options.projectID = projectID
            options.apiKey = apiKey
            options.storageBucket = storageBucket
            options.bundleID = Bundle.main.bundleIdentifier ?? ""
            return options
        }

        init(
            projectID: String,
            apiKey: String,
            loggingLevel: LogLevel,
            useEmulator: Bool,
            storageBucket: String? = nil,
            googleAppID: String? = nil,
            gcmSenderID: String? = nil,
            measurementId: String? = nil
        ) {
            self.projectID = projectID
            self.apiKey = apiKey
            self.loggingLevel = loggingLevel
            self.useEmulator = useEmulator
            self.storageBucket = storageBucket ?? "\(projectID).appspot.com"
            self.googleAppID = googleAppID ?? projectID
            self.gcmSenderID = gcmSenderID ?? ""  // Not using FCM by default
            self.measurementId = measurementId
        }
    }

    // MARK: - Properties
    private var currentEnvironment: Environment = .development
    private var isInitialized = false

    // Cache Firebase service instances since they're thread-safe
    nonisolated private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let functions = Functions.functions()

    // MARK: - Configuration Methods
    func config(for environment: Environment) async throws -> Config {
        switch environment {
        case .development:
            guard let projectID = ProcessInfo.processInfo.environment["FIREBASE_PROJECT_ID"],
                let apiKey = ProcessInfo.processInfo.environment["FIREBASE_API_KEY"],
                let googleAppID = ProcessInfo.processInfo.environment["FIREBASE_APP_ID"]
            else {
                throw FirebaseError.missingConfiguration(
                    "Required Firebase environment variables are missing")
            }
            return Config(
                projectID: projectID,
                apiKey: apiKey,
                loggingLevel: .debug,
                useEmulator: true,
                googleAppID: googleAppID,
                gcmSenderID: ProcessInfo.processInfo.environment["FIREBASE_MESSAGING_SENDER_ID"],
                measurementId: ProcessInfo.processInfo.environment["FIREBASE_MEASUREMENT_ID"]
            )

        case .production:
            guard let projectID = ProcessInfo.processInfo.environment["PROD_FIREBASE_PROJECT_ID"],
                let apiKey = ProcessInfo.processInfo.environment["PROD_FIREBASE_API_KEY"],
                let googleAppID = ProcessInfo.processInfo.environment["PROD_FIREBASE_APP_ID"]
            else {
                throw FirebaseError.missingConfiguration(
                    "Required Firebase production environment variables are missing")
            }
            return Config(
                projectID: projectID,
                apiKey: apiKey,
                loggingLevel: .warning,
                useEmulator: false,
                googleAppID: googleAppID,
                gcmSenderID: ProcessInfo.processInfo.environment[
                    "PROD_FIREBASE_MESSAGING_SENDER_ID"],
                measurementId: ProcessInfo.processInfo.environment["PROD_FIREBASE_MEASUREMENT_ID"]
            )
        }
    }

    // MARK: - Initialization
    func initialize(environment: Environment) async throws {
        guard !isInitialized else { return }

        currentEnvironment = environment
        let config = try await config(for: environment)

        FirebaseApp.configure(options: config.firebaseOptions)

        if config.useEmulator {
            useEmulators()
        }

        isInitialized = true
    }

    // MARK: - Emulator Configuration
    private func useEmulators() {
        auth.useEmulator(withHost: "localhost", port: 9099)

        let settings = FirestoreSettings()
        settings.host = "localhost:8080"
        settings.cacheSettings = PersistentCacheSettings()
        settings.isSSLEnabled = false
        db.settings = settings

        storage.useEmulator(withHost: "localhost", port: 9199)
        functions.useEmulator(withHost: "localhost", port: 5001)
    }
}

// MARK: - Logging Level
enum LogLevel: String {
    case debug
    case info
    case warning
    case error
}

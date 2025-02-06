import FirebaseCore
import Foundation

/// A type-safe Firebase configuration struct
struct FirebaseConfig: Sendable {
    let projectID: String
    let apiKey: String
    let authDomain: String
    let storageBucket: String
    let appID: String
    let messagingSenderID: String
    let measurementID: String?

    var firebaseOptions: FirebaseOptions {
        let options = FirebaseOptions(
            googleAppID: appID,
            gcmSenderID: messagingSenderID
        )
        options.projectID = projectID
        options.apiKey = apiKey
        options.storageBucket = storageBucket
        options.bundleID = Bundle.main.bundleIdentifier ?? ""
        if let measurementID = measurementID {
            options.trackingID = measurementID
        }
        return options
    }
}

/// A global actor for Firebase initialization and configuration
@globalActor
final actor FirebaseClient {
    static let shared = FirebaseClient()
    private var isInitialized = false
    private var currentEnvironment: Environment?

    enum Environment: String {
        case development
        case production
    }

    private init() {}

    /// Initializes Firebase with the specified configuration
    func initialize(environment: Environment) async throws {
        guard !isInitialized else { return }

        let config = try await loadConfig(for: environment)
        FirebaseApp.configure(options: config.firebaseOptions)

        if environment == .development
            && ProcessInfo.processInfo.environment["FIREBASE_USE_EMULATOR"] == "YES"
        {
            try await useEmulators()
        }

        currentEnvironment = environment
        isInitialized = true
    }

    /// Loads Firebase configuration from environment variables
    private func loadConfig(for environment: Environment) async throws -> FirebaseConfig {
        let processInfo = ProcessInfo.processInfo
        let envPrefix = environment == .development ? "" : "PROD_"

        guard let projectID = processInfo.environment["\(envPrefix)FIREBASE_PROJECT_ID"],
            let apiKey = processInfo.environment["\(envPrefix)FIREBASE_API_KEY"],
            let appID = processInfo.environment["\(envPrefix)FIREBASE_APP_ID"],
            let messagingSenderID = processInfo.environment[
                "\(envPrefix)FIREBASE_MESSAGING_SENDER_ID"]
        else {
            throw FirebaseError.missingConfiguration
        }

        return FirebaseConfig(
            projectID: projectID,
            apiKey: apiKey,
            authDomain: "\(projectID).firebaseapp.com",
            storageBucket: "\(projectID).appspot.com",
            appID: appID,
            messagingSenderID: messagingSenderID,
            measurementID: processInfo.environment["\(envPrefix)FIREBASE_MEASUREMENT_ID"]
        )
    }

    /// Configures Firebase to use local emulators
    private func useEmulators() async throws {
        // Configure emulators based on environment variables
        let processInfo = ProcessInfo.processInfo

        if let authHost = processInfo.environment["FIREBASE_AUTH_EMULATOR_HOST"],
            let authPort = processInfo.environment["FIREBASE_AUTH_EMULATOR_PORT"]
        {
            Auth.auth().useEmulator(withHost: authHost, port: Int(authPort) ?? 9099)
        }

        if let firestoreHost = processInfo.environment["FIREBASE_FIRESTORE_EMULATOR_HOST"],
            let firestorePort = processInfo.environment["FIREBASE_FIRESTORE_EMULATOR_PORT"]
        {
            Firestore.firestore().useEmulator(
                withHost: firestoreHost, port: Int(firestorePort) ?? 8080)
        }

        if let functionsHost = processInfo.environment["FIREBASE_FUNCTIONS_EMULATOR_HOST"],
            let functionsPort = processInfo.environment["FIREBASE_FUNCTIONS_EMULATOR_PORT"]
        {
            Functions.functions().useEmulator(
                withHost: functionsHost, port: Int(functionsPort) ?? 5001)
        }

        if let storageHost = processInfo.environment["FIREBASE_STORAGE_EMULATOR_HOST"],
            let storagePort = processInfo.environment["FIREBASE_STORAGE_EMULATOR_PORT"]
        {
            Storage.storage().useEmulator(withHost: storageHost, port: Int(storagePort) ?? 9199)
        }
    }
}

/// Firebase-specific errors
enum FirebaseError: LocalizedError {
    case missingConfiguration
    case invalidEnvironment
    case initializationError(String)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Missing required Firebase configuration values"
        case .invalidEnvironment:
            return "Invalid Firebase environment"
        case .initializationError(let message):
            return "Firebase initialization error: \(message)"
        }
    }
}

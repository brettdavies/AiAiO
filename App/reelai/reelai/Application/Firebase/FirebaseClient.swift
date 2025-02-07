import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage
import Foundation

/// A global actor for Firebase initialization and configuration
@globalActor
final actor FirebaseClient {
    static let shared = FirebaseClient()
    private var isInitialized = false
    private var currentEnvironment: FirebaseEnvironment.Environment?
    nonisolated private let auth = Auth.auth()  // Firebase Auth is thread-safe
    private let db = Firestore.firestore()  // Firestore is thread-safe
    private let functions = Functions.functions()  // Functions is thread-safe
    private let storage = Storage.storage()  // Storage is thread-safe

    private init() {}

    /// Initializes Firebase with the specified configuration
    func initialize(environment: FirebaseEnvironment.Environment) async throws {
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
    private func loadConfig(for environment: FirebaseEnvironment.Environment) async throws
        -> FirebaseEnvironment.Config
    {
        let processInfo = ProcessInfo.processInfo
        let envPrefix = environment == .development ? "" : "PROD_"

        guard let projectID = processInfo.environment["\(envPrefix)FIREBASE_PROJECT_ID"],
            let apiKey = processInfo.environment["\(envPrefix)FIREBASE_API_KEY"],
            let googleAppID = processInfo.environment["\(envPrefix)FIREBASE_APP_ID"]
        else {
            throw FirebaseError.missingConfiguration(
                "Missing required Firebase configuration values"
            )
        }

        return FirebaseEnvironment.Config(
            projectID: projectID,
            apiKey: apiKey,
            loggingLevel: environment == .development ? .debug : .warning,
            useEmulator: environment == .development,
            googleAppID: googleAppID,
            gcmSenderID: processInfo.environment["\(envPrefix)FIREBASE_MESSAGING_SENDER_ID"],
            measurementId: processInfo.environment["\(envPrefix)FIREBASE_MEASUREMENT_ID"]
        )
    }

    /// Configures Firebase to use local emulators
    private func useEmulators() async throws {
        let processInfo = ProcessInfo.processInfo

        // Configure Auth emulator
        if let authHost = processInfo.environment["FIREBASE_AUTH_EMULATOR_HOST"],
            let authPort = processInfo.environment["FIREBASE_AUTH_EMULATOR_PORT"]
        {
            guard let port = Int(authPort) else {
                throw FirebaseError.invalidConfiguration("Invalid Auth emulator port")
            }
            auth.useEmulator(withHost: authHost, port: port)
        }

        // Configure Firestore emulator
        if let firestoreHost = processInfo.environment["FIREBASE_FIRESTORE_EMULATOR_HOST"],
            let firestorePort = processInfo.environment["FIREBASE_FIRESTORE_EMULATOR_PORT"]
        {
            guard let port = Int(firestorePort) else {
                throw FirebaseError.invalidConfiguration("Invalid Firestore emulator port")
            }
            db.settings = FirestoreSettings()
            db.settings.host = "\(firestoreHost):\(port)"
            db.settings.cacheSettings = PersistentCacheSettings()
            db.settings.isSSLEnabled = false
        }

        // Configure Functions emulator
        if let functionsHost = processInfo.environment["FIREBASE_FUNCTIONS_EMULATOR_HOST"],
            let functionsPort = processInfo.environment["FIREBASE_FUNCTIONS_EMULATOR_PORT"]
        {
            guard let port = Int(functionsPort) else {
                throw FirebaseError.invalidConfiguration("Invalid Functions emulator port")
            }
            functions.useEmulator(withHost: functionsHost, port: port)
        }

        // Configure Storage emulator
        if let storageHost = processInfo.environment["FIREBASE_STORAGE_EMULATOR_HOST"],
            let storagePort = processInfo.environment["FIREBASE_STORAGE_EMULATOR_PORT"]
        {
            guard let port = Int(storagePort) else {
                throw FirebaseError.invalidConfiguration("Invalid Storage emulator port")
            }
            storage.useEmulator(withHost: storageHost, port: port)
        }
    }
}

/// Firebase-specific errors
enum FirebaseError: LocalizedError {
    case missingConfiguration(String)
    case invalidConfiguration(String)
    case initializationError(String)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration(let message):
            return "Missing required Firebase configuration: \(message)"
        case .invalidConfiguration(let message):
            return "Invalid Firebase configuration: \(message)"
        case .initializationError(let message):
            return "Firebase initialization error: \(message)"
        }
    }
}

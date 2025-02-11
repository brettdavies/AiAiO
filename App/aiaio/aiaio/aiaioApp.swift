import SwiftData
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions
import FirebaseFirestore

@main
struct AiAiOApp: App {
    // Shared services.
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var sessionManager = SessionManager()
    
    init() {
        UnifiedLogger.log("App initializing in \(Environment.current) environment", level: .info)
        configureFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkMonitor)
                .environmentObject(sessionManager)
        }
    }
    
    /// Configure Firebase for the current environment.
    private func configureFirebase() {
        FirebaseApp.configure()
        
        if Environment.current.useFirebaseEmulator {
            UnifiedLogger.log("Configuring Firebase emulators", level: .info)
            Auth.auth().useEmulator(withHost: "localhost", port: 9099)
            Storage.storage().useEmulator(withHost: "localhost", port: 9199)
            
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isSSLEnabled = false
            settings.cacheSettings = MemoryCacheSettings()
            Firestore.firestore().settings = settings
            
            Functions.functions().useEmulator(withHost: "localhost", port: 5001)
        } else {
            UnifiedLogger.log("Using production Firebase services", level: .info)
        }
    }
}

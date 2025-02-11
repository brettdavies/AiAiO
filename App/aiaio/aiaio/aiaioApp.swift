//
//  aiaioApp.swift
//  aiaio
//
//  Created by Brett on 2/10/25.
//

import SwiftData
import SwiftUI

@main
struct AiAiOApp: App {
    init() {
        // Configure app on launch
        UnifiedLogger.log("App initializing in \(Environment.current) environment", level: .info)
        configureFirebase()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    /// Configure Firebase for the current environment
    private func configureFirebase() {
        FirebaseApp.configure()

        if Environment.current.useFirebaseEmulator {
            UnifiedLogger.log("Configuring Firebase emulators", level: .info)
            Auth.auth().useEmulator(withHost: "localhost", port: 9099)
            Storage.storage().useEmulator(withHost: "localhost", port: 9199)
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isSSLEnabled = false
            settings.isPersistenceEnabled = true
            Firestore.firestore().settings = settings
            Functions.functions().useEmulator(withHost: "localhost", port: 5001)
        } else {
            UnifiedLogger.log("Using production Firebase services", level: .info)
        }
    }
}

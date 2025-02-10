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
        // TODO: Add Firebase configuration in Task 1.3
        UnifiedLogger.log("Firebase configuration pending", level: .warning)
    }
}

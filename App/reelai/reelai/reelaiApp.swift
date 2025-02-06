//
//  reelaiApp.swift
//  reelai
//
//  Created by Brett on 2/4/25.
//

import SwiftData
import SwiftUI

@main
struct reelaiApp: App {
    init() {
        // Initialize the unified logger and log the startup event.
        UnifiedLogger.shared.log(level: .info, message: "ReelAIApp is starting up.")
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

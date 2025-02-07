//
//  reelaiApp.swift
//  reelai
//
//  Created by Brett on 2/4/25.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase initialization is now handled by FirebaseClient in ContentView
        // to properly handle async initialization and errors
        return true
    }
}

@main
struct reelaiApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Initialize AuthService at app level
    private let authService: AuthService
    private let environment: FirebaseEnvironment.Environment

    init() {
        self.authService = AuthService()
        // Determine environment based on build configuration
        #if DEBUG
            self.environment = .development
        #else
            self.environment = .production
        #endif

        // Log application startup using LogManager
        Task {
            await LogManager.shared.log(
                level: .info,
                message: "ReelAIApp is starting up.",
                metadata: ["category": LogCategory.app.rawValue]
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(authService: authService, environment: environment)
        }
    }
}

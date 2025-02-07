//
//  ContentView.swift
//  reelai
//
//  Created by Brett on 2/4/25.
//  Location: Application/Views/ContentView.swift
//

// Firebase frameworks
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore
// System frameworks
import Foundation
// Third-party frameworks
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    // MARK: - Properties
    private let authService: AuthService
    @StateObject private var authViewModel: AuthViewModel
    @State private var initializationError: Error?
    private let environment: FirebaseEnvironment.Environment

    // MARK: - Initialization
    init(authService: AuthService, environment: FirebaseEnvironment.Environment = .development) {
        self.authService = authService
        let viewModel = AuthViewModel(authService: authService, environment: environment)
        self._authViewModel = StateObject(wrappedValue: viewModel)
        self.environment = environment
    }
    // MARK: - Body
    var body: some View {
        Group {
            if let error = authViewModel.error {
                VStack(spacing: 16) {
                    Text("Initialization Error")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                    Button("Retry") {
                        authViewModel.initialize()
                    }
                }
                .padding()
            } else if !authViewModel.isInitialized {
                ProgressView("Initializing...")
            } else {
                mainContent
            }
        }
        .task {
            guard !authViewModel.isInitialized else { return }
            authViewModel.initialize()
        }
    }

    // MARK: - Main Content View
    @ViewBuilder
    private var mainContent: some View {
        if authViewModel.isAuthenticated {
            VStack {
                EmailVerificationBannerView(viewModel: authViewModel)

                // Main content here
                Text("Welcome \(authViewModel.currentUser?.email ?? "")")
                    .padding()

                Button("Sign Out") {
                    authViewModel.signOut()
                }
            }
        } else {
            SignInView(
                authService: authService,
                environment: environment
            )
        }
    }
}

import SwiftUI

// MARK: - UnauthenticatedContentView
struct UnauthenticatedContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        VStack {
            if !networkMonitor.isConnected {
                Text("No network connection. Please check your connection.")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.vertical, 8)
            }
            Spacer()
            Image(systemName: "video.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.system(size: 60))
            Text("Welcome to AiAiO")
                .font(.title)
                .padding(.top)
            Text("Your AI-powered video platform")
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 16) {
                Button("Sign In") {
                    authViewModel.activeAuthSheet = .signIn
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!networkMonitor.isConnected)
                
                Button("Sign Up") {
                    authViewModel.activeAuthSheet = .signUp
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!networkMonitor.isConnected)
            }
            .padding(.horizontal)
        }
        .sheet(item: $authViewModel.activeAuthSheet) { sheet in
            switch sheet {
            case .signIn:
                SignInView()
                    .environmentObject(authViewModel)
                    .environmentObject(networkMonitor)
            case .signUp:
                SignUpView()
                    .environmentObject(authViewModel)
                    .environmentObject(networkMonitor)
            }
        }
    }
}
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            if sessionManager.isSignedIn {
                // Main content for authenticated users.
                VStack(spacing: 16) {
                    // Optionally display a network status banner.
                    if !networkMonitor.isConnected {
                        Text("Network connection lost. Some features may be unavailable.")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    Image(systemName: "video.fill")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Welcome to AiAiO")
                        .font(.title)
                    Text("Your AI-powered video platform")
                        .foregroundStyle(.secondary)

                    NavigationLink("View Groups") {
                        GroupListView()
                    }
                    .padding(.top)

                    Button("Sign Out") {
                        sessionManager.signOut()
                    }
                    .padding(.top)
                }
                .padding()
                .navigationTitle("AiAiO")
            } else {
                // Unauthenticated view presenting options to sign in or sign up.
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
                    
                    // Two buttons to choose the desired auth flow.
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
                // Present the appropriate modal based on activeAuthSheet.
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionManager())
            .environmentObject(NetworkMonitor())
    }
}

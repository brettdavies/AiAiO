import SwiftUI

// Define an enum to track which auth screen should be presented.
enum AuthSheet: Identifiable {
    case signIn, signUp
    var id: Int { hashValue }
}

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            if authViewModel.isSignedIn {
                // Main content for authenticated users.
                VStack(spacing: 16) {
                    Image(systemName: "video.fill")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Welcome to AiAiO")
                        .font(.title)
                    Text("Your AI-powered video platform")
                        .foregroundStyle(.secondary)
                    
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .padding(.top)
                }
                .padding()
                .navigationTitle("AiAiO")
            } else {
                // Unauthenticated view presenting options to sign in or sign up.
                VStack {
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
                    
                    // Two buttons side-by-side to choose the desired auth flow.
                    HStack(spacing: 16) {
                        Button("Sign In") {
                            authViewModel.activeAuthSheet = .signIn
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Sign Up") {
                            authViewModel.activeAuthSheet = .signUp
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                // Present the appropriate modal based on the activeAuthSheet value.
                .sheet(item: $authViewModel.activeAuthSheet) { sheet in
                    switch sheet {
                    case .signIn:
                        SignInView()
                            .environmentObject(authViewModel)
                    case .signUp:
                        SignUpView()
                            .environmentObject(authViewModel)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

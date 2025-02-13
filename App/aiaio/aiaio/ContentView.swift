import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            if sessionManager.isSignedIn {
                AuthenticatedContentView()
                    .navigationTitle("My Videos")
            } else {
                UnauthenticatedContentView()
                    .environmentObject(authViewModel)
                    .environmentObject(networkMonitor)
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionManager())
            .environmentObject(NetworkMonitor())
    }
}

import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var localError: String?  // Removed redundant initialization
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            if !networkMonitor.isConnected {
                Text("No network connection. Please check your connection.")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.vertical, 8)
            }
            
            Text("Sign In")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            TextField("Email", text: $email)
                .textFieldStyle(.plain)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .inputFieldStyle()
            
            SecureField("Password", text: $password)
                .textFieldStyle(.plain)
                .textContentType(.password)
                .inputFieldStyle()
            
            if isLoading {
                ProgressView()
            }
            
            if let error = localError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Button(action: {
                Task {
                    isLoading = true
                    do {
                        try await authViewModel.signIn(email: email, password: password)
                        authViewModel.activeAuthSheet = nil
                        localError = nil
                    } catch {
                        localError = error.localizedDescription
                    }
                    isLoading = false
                }
            }, label: {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            })
            .disabled(!networkMonitor.isConnected)
        }
        .padding()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthViewModel())
            .environmentObject(NetworkMonitor())
    }
}

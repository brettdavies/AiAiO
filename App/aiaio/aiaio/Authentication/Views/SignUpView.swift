import SwiftUI

struct SignUpView: View {
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
            
            Text("Sign Up")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            TextField("Email", text: $email)
                .textFieldStyle(.plain)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .inputFieldStyle()
            
            SecureField("Password", text: $password)
                .textFieldStyle(.plain)
                .textContentType(.newPassword)
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
                        try await authViewModel.signUp(email: email, password: password)
                        authViewModel.activeAuthSheet = nil
                        localError = nil
                    } catch {
                        localError = error.localizedDescription
                    }
                    isLoading = false
                }
            }, label: {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            })
            .disabled(!networkMonitor.isConnected)
        }
        .padding()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())
            .environmentObject(NetworkMonitor())
    }
}

import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
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
            
            if authViewModel.isLoading {
                ProgressView()
            }
            
            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
            
            Button(action: {
                Task {
                    await authViewModel.signIn(email: email, password: password)
                }
            }, label: {
                Text("Sign In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            })
        }
        .padding()
    }
}

#Preview {
    SignInView()
}

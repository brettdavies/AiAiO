import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
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
                    await authViewModel.signUp(email: email, password: password)
                }
            }, label: {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            })
        }
        .padding()
    }
}

#Preview {
    SignUpView()
}

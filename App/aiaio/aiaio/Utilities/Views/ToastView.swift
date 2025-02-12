import SwiftUI

/// A simple view that displays a toast message.
struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.top, 44) // Adjust for status bar / safe area.
    }
}

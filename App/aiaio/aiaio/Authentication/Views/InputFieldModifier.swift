import SwiftUI

struct InputFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.thinMaterial)
            .cornerRadius(8)
    }
}

extension View {
    func inputFieldStyle() -> some View {
        modifier(InputFieldModifier())
    }
}

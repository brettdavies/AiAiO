import SwiftUI

struct RootView: View {
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        ZStack {
            ContentView()
            if toastManager.isVisible {
                VStack {
                    ToastView(message: toastManager.message)
                        .transition(.move(edge: .top))
                    Spacer()
                }
                .animation(.easeInOut, value: toastManager.isVisible)
            }
        }
    }
}

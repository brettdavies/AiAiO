import SwiftUI

/// A global manager for displaying toast notifications across the app.
final class ToastManager: ObservableObject, @unchecked Sendable {
    @Published var isVisible: Bool = false
    @Published var message: String = ""
    
    /// Displays a toast with the given message for the specified duration.
    /// - Parameters:
    ///   - message: The message to display.
    ///   - duration: Duration in seconds for which the toast is visible.
    func showToast(message: String, duration: TimeInterval = 2.0) {
        self.message = message
        withAnimation {
            isVisible = true
        }
        Task {
            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            await MainActor.run {
                withAnimation {
                    self.isVisible = false
                }
            }
        }
    }
}

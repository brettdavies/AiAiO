import Foundation
import Network
import Combine

/// Monitors network connectivity using NWPathMonitor and publishes the connection status.
final class NetworkMonitor: ObservableObject, @unchecked Sendable {
    @Published var isConnected: Bool = true

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    init() {
        monitor = NWPathMonitor()
        UnifiedLogger.info("NetworkMonitor initialized", context: "Network")
        monitor.pathUpdateHandler = { [weak self] path in
            // Use a Task to run the assignment on the main actor.
            Task { @MainActor in
                let wasConnected = self?.isConnected ?? true
                self?.isConnected = (path.status == .satisfied)

                if wasConnected && !(self?.isConnected ?? true) {
                    UnifiedLogger.warning("Network connectivity lost", context: "Network")
                } else if !wasConnected && (self?.isConnected ?? false) {
                    UnifiedLogger.info("Network connectivity restored", context: "Network")
                }
                UnifiedLogger.info("Network status: \(self?.isConnected ?? false)", context: "NetworkMonitor")
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        UnifiedLogger.info("NetworkMonitor deinitialized", context: "Network")
        monitor.cancel()
    }
}

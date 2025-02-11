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
        monitor.pathUpdateHandler = { [weak self] path in
            // Use a Task to run the assignment on the main actor.
            Task { @MainActor in
                self?.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

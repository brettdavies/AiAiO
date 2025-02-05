//
//  Logger.swift
//  reelai
//
//  Created by Brett on 2/4/25.
//

import Foundation
import Network
import FirebaseCrashlytics

public enum LogLevel: String {
    case info = "INFO"
    case debug = "DEBUG"
    case warning = "WARNING"
    case error = "ERROR"
}

public protocol Logger {
    func log(level: LogLevel, message: String)
}

public final class UnifiedLogger: Logger {

    // Shared instance for global use
    public static let shared = UnifiedLogger()

    // In-memory cache for log messages
    private var logCache: [(level: LogLevel, message: String)] = []
    private let cacheQueue = DispatchQueue(label: "com.reelai.logger.cacheQueue")

    // Network monitor to detect connectivity changes
    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue.global(qos: .background)

    private init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.flushCache()
            }
        }
        monitor.start(queue: monitorQueue)

        // Log initialization confirmation
        log(level: .info, message: "UnifiedLogger initialized.")
    }

    public func log(level: LogLevel, message: String) {
        let formattedMessage = "\(level.rawValue): \(message)"

        // Immediately print to console
        print(formattedMessage)

        // If online, send error (or warning) logs to Firebase Crashlytics; otherwise, cache the log.
        if isConnected() {
            if level == .error || level == .warning {
                Crashlytics.crashlytics().log(formattedMessage)
            }
        } else {
            cacheQueue.async { [weak self] in
                self?.logCache.append((level, message))
            }
        }
    }

    // Helper method to check network connectivity.
    private func isConnected() -> Bool {
        return monitor.currentPath.status == .satisfied
    }

    // Flush cached log messages to Firebase Crashlytics when connectivity is restored.
    private func flushCache() {
        cacheQueue.async { [weak self] in
            guard let self = self, !self.logCache.isEmpty else { return }
            for (level, message) in self.logCache {
                let formattedMessage = "\(level.rawValue): \(message)"
                if level == .error || level == .warning {
                    Crashlytics.crashlytics().log(formattedMessage)
                }
            }
            self.logCache.removeAll()
        }
    }
}

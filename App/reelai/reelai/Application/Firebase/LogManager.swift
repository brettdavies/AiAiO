import FirebaseAnalytics
import Foundation
import OSLog

/// A type-safe logging manager that handles both development and production logging
@globalActor
final actor LogManager: Sendable {
    // MARK: - Types

    /// Log levels matching OSLog severity
    enum LogLevel: String, Sendable {
        case debug
        case info
        case warning
        case error

        fileprivate var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .error
            case .error: return .fault
            }
        }
    }

    /// Configuration for log retention
    private struct RetentionConfig: Sendable {
        let maxAgeDays: Int
        let maxSizeBytes: Int64

        // ProcessInfo is thread-safe
        nonisolated private static var processInfo: ProcessInfo { ProcessInfo.processInfo }

        static let development = RetentionConfig(
            maxAgeDays: Int(processInfo.environment["LOG_RETENTION_DAYS"] ?? "7") ?? 7,
            maxSizeBytes: Int64(processInfo.environment["LOG_MAX_SIZE_MB"] ?? "50")!
                * 1024 * 1024
        )

        static let production = RetentionConfig(
            maxAgeDays: Int(processInfo.environment["LOG_RETENTION_DAYS"] ?? "3") ?? 3,
            maxSizeBytes: Int64(processInfo.environment["LOG_MAX_SIZE_MB"] ?? "10")!
                * 1024 * 1024
        )
    }

    // MARK: - Properties

    static let shared = LogManager()

    private let logger: Logger
    private var cleanupTask: Task<Void, Never>?

    // System APIs are thread-safe
    private let fileManager = FileManager.default
    nonisolated private var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "com.reelai"
    }
    nonisolated private let calendar = Calendar.current
    nonisolated private var now: Date { Date() }

    // MARK: - Initialization

    private init() {
        // Initialize stored properties first
        self.logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "com.reelai", category: "app")
        // Schedule cleanup after full initialization
        Task { [self] in await scheduleCleanup() }
    }

    deinit {
        cleanupTask?.cancel()
    }

    // MARK: - Logging Methods

    /// Logs a message with the specified level and optional metadata
    /// - Parameters:
    ///   - level: The severity level of the log
    ///   - message: The message to log
    ///   - error: Optional error to include
    ///   - metadata: Optional key-value pairs for additional context
    func log(
        level: LogLevel,
        message: String,
        error: Error? = nil,
        metadata: [String: Any]? = nil
    ) async {
        #if DEBUG
            // Development logging using os.Logger
            let logMessage = metadata?.isEmpty == false ? "\(message) \(metadata!)" : message
            logger.log(level: level.osLogType, "\(logMessage, privacy: .public)")
        #else
            // Production logging to Firebase
            switch level {
            case .error:
                if let error = error {
                    crashlytics.record(error: error)
                } else {
                    crashlytics.log("ERROR: \(message)")
                }
                if let metadata = metadata {
                    Analytics.logEvent("error", parameters: metadata)
                }
            case .warning:
                crashlytics.log("WARNING: \(message)")
                if let metadata = metadata {
                    Analytics.logEvent("warning", parameters: metadata)
                }
            case .info:
                if let metadata = metadata {
                    Analytics.logEvent(message, parameters: metadata)
                }
            case .debug:
                break  // No debug logging in production
            }
        #endif
    }

    // MARK: - Cleanup Methods

    private func scheduleCleanup() async {
        cleanupTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.performCleanup()
                try? await Task.sleep(nanoseconds: 24 * 60 * 60 * 1_000_000_000)  // Daily cleanup
            }
        }
    }

    private func performCleanup() async {
        #if DEBUG
            let config = RetentionConfig.development
        #else
            let config = RetentionConfig.production
        #endif

        guard
            let logDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("Logs")
        else { return }

        let resourceKeys: Set<URLResourceKey> = [.creationDateKey, .fileSizeKey]
        let enumerator = fileManager.enumerator(
            at: logDirectory,
            includingPropertiesForKeys: Array(resourceKeys),
            options: [.skipsHiddenFiles]
        )

        var totalSize: Int64 = 0
        var filesToDelete: [URL] = []

        // First pass: Calculate total size and identify old files
        while let fileURL = enumerator?.nextObject() as? URL {
            guard let resources = try? fileURL.resourceValues(forKeys: resourceKeys),
                let creationDate = resources.creationDate,
                let fileSize = resources.fileSize
            else { continue }

            let fileAge = calendar.dateComponents(
                [.day], from: creationDate, to: now)
            if let days = fileAge.day, days > config.maxAgeDays {
                filesToDelete.append(fileURL)
            } else {
                totalSize += Int64(fileSize)
            }
        }

        // Delete old files
        for fileURL in filesToDelete {
            try? fileManager.removeItem(at: fileURL)
            await log(
                level: .debug, message: "Cleaned up old log file: \(fileURL.lastPathComponent)")
        }

        // If still over size limit, remove oldest files until under limit
        if totalSize > config.maxSizeBytes {
            let enumerator = fileManager.enumerator(
                at: logDirectory,
                includingPropertiesForKeys: Array(resourceKeys)
            )

            var files: [(url: URL, date: Date)] = []
            while let fileURL = enumerator?.nextObject() as? URL {
                guard let resources = try? fileURL.resourceValues(forKeys: resourceKeys),
                    let creationDate = resources.creationDate
                else { continue }
                files.append((fileURL, creationDate))
            }

            // Sort by date, oldest first
            files.sort { $0.date < $1.date }

            // Remove oldest files until under size limit
            for file in files {
                if totalSize <= config.maxSizeBytes { break }
                if let fileSize = try? file.url.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    try? fileManager.removeItem(at: file.url)
                    totalSize -= Int64(fileSize)
                    await log(
                        level: .debug,
                        message: "Cleaned up log file due to size: \(file.url.lastPathComponent)")
                }
            }
        }

        // Log any errors that occurred during cleanup
        if totalSize > config.maxSizeBytes {
            await log(
                level: .warning,
                message: "Log cleanup incomplete: Still \(totalSize) bytes over limit")
        }
    }
}

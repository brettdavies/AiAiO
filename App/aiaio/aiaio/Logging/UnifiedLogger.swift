import Foundation
import os.log

/// A unified logging system for consistent logging across the app
enum UnifiedLogger {
    // MARK: - Types

    /// Log levels for different types of messages
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"

        /// The corresponding OS Log type
        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .error  // Using .error for warnings to make them more visible
            case .error:
                return .error
            }
        }
    }

    // MARK: - Properties

    /// The subsystem identifier for the logger
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.aiaio"

    /// Category-specific loggers
    private static let appLogger = OSLog(subsystem: subsystem, category: "App")
    private static let networkLogger = OSLog(subsystem: subsystem, category: "Network")
    private static let authLogger = OSLog(subsystem: subsystem, category: "Auth")
    private static let videoLogger = OSLog(subsystem: subsystem, category: "Video")

    // MARK: - Logging Methods

    /// Log a message with the specified level and optional context
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The severity level of the log
    ///   - context: Optional context to help identify the source of the log
    ///   - file: The file where the log was called (automatically captured)
    ///   - function: The function where the log was called (automatically captured)
    ///   - line: The line where the log was called (automatically captured)
    static func log(
        _ message: String,
        level: Level,
        context: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent
        let contextInfo = context.map { "[\($0)] " } ?? ""
        let logMessage = "\(contextInfo)[\(fileName):\(line)] \(function): \(message)"

        // Determine the appropriate logger based on context or default to app logger
        let logger: OSLog
        if let context = context?.lowercased() {
            switch context {
            case _ where context.contains("network"):
                logger = networkLogger
            case _ where context.contains("auth"):
                logger = authLogger
            case _ where context.contains("video"):
                logger = videoLogger
            default:
                logger = appLogger
            }
        } else {
            logger = appLogger
        }

        // Log the message using os_log
        os_log(
            level.osLogType,
            log: logger,
            "%{public}@",
            logMessage
        )

        #if DEBUG
            // In debug builds, also print to console for easier debugging
            let emoji: String
            switch level {
            case .debug: emoji = "🔍"
            case .info: emoji = "ℹ️"
            case .warning: emoji = "⚠️"
            case .error: emoji = "❌"
            }
            print("\(emoji) \(level.rawValue): \(logMessage)")
        #endif
    }

    // MARK: - Convenience Methods

    static func debug(_ message: String, context: String? = nil) {
        log(message, level: .debug, context: context)
    }

    static func info(_ message: String, context: String? = nil) {
        log(message, level: .info, context: context)
    }

    static func warning(_ message: String, context: String? = nil) {
        log(message, level: .warning, context: context)
    }

    static func error(_ message: String, context: String? = nil) {
        log(message, level: .error, context: context)
    }

    static func error(_ error: Error, context: String? = nil) {
        if let globalError = error as? GlobalError {
            log(globalError.localizedDescription, level: .error, context: context)
        } else {
            log(error.localizedDescription, level: .error, context: context)
        }
    }
}

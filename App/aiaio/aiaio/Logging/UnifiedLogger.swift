import Foundation
import os.log

/// Unified logging system for the app
enum UnifiedLogger {
    /// Log levels supported by the logger
    enum Level: String {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"

        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .default
            case .error:
                return .error
            }
        }
    }

    /// Main logger instance
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.gauntlet.aiaio",
        category: "App"
    )

    /// Log a message with the specified level
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    ///   - file: The file where the log was called
    ///   - function: The function where the log was called
    ///   - line: The line number where the log was called
    static func log(
        _ message: String,
        level: Level = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let metadata = "\(file.split(separator: "/").last ?? ""):\(line) - \(function)"
        let logMessage = "[\(level.rawValue)] \(metadata) | \(message)"
        logger.log(level: level.osLogType, "\(logMessage)")
    }
}

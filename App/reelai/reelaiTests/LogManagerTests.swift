import XCTest

@testable import reelai

final class LogManagerTests: XCTestCase {
    func testLogging() async throws {
        let manager = LogManager.shared

        // Test different log levels
        await manager.log(level: .debug, message: "Debug message")
        await manager.log(level: .info, message: "Info message")
        await manager.log(level: .warning, message: "Warning message")
        await manager.log(level: .error, message: "Error message")

        // Test with metadata
        await manager.log(
            level: .info,
            message: "Message with metadata",
            metadata: ["key": "value"]
        )

        // Test with error
        struct TestError: Error {}
        await manager.log(
            level: .error,
            message: "Error with details",
            error: TestError(),
            metadata: ["errorType": "test"]
        )
    }

    func testLogCleanup() async throws {
        let manager = LogManager.shared

        // Create some test logs
        for i in 0..<100 {
            await manager.log(level: .debug, message: "Test log \(i)")
        }

        // Force cleanup
        await manager.performCleanup()

        // Verify cleanup
        let logDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("Logs")

        XCTAssertNotNil(logDirectory)

        if let logDirectory = logDirectory {
            let files = try FileManager.default.contentsOfDirectory(
                at: logDirectory,
                includingPropertiesForKeys: [.fileSizeKey]
            )

            let totalSize = files.reduce(0) { sum, file in
                guard let size = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
                    return sum
                }
                return sum + Int64(size)
            }

            #if DEBUG
                XCTAssertLessThanOrEqual(
                    totalSize, LogManager.RetentionConfig.development.maxSizeBytes)
            #else
                XCTAssertLessThanOrEqual(
                    totalSize, LogManager.RetentionConfig.production.maxSizeBytes)
            #endif
        }
    }
}

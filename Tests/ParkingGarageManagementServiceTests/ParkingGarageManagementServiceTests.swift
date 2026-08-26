@testable import ParkingGarageManagementService
import VaporTesting
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct ParkingGarageManagementServiceTests {
    /// Internal (not private) so other files can extend this suite with additional `@Test`s that
    /// reuse it. Garage/Floor/Space tests, and any future resource tests, must live in this same
    /// suite rather than a separate `@Suite` - `.serialized` only serializes tests within a suite,
    /// and separate suites run concurrently, which races migrations against the shared test database.
    func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
}

import Fluent

struct CreateGarage: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("garages")
            .id()
            .field("name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("garages").delete()
    }
}

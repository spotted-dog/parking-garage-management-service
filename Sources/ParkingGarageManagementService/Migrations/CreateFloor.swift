import Fluent

struct CreateFloor: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("floors")
            .id()
            .field("floor_number", .string, .required)
            .field("garage_id", .uuid, .required, .references("garages", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "garage_id", "floor_number")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("floors").delete()
    }
}

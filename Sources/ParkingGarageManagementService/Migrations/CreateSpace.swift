import Fluent

struct CreateSpace: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("spaces")
            .id()
            .field("space_number", .int, .required)
            .field("available", .bool, .required)
            .field("floor_id", .uuid, .required, .references("floors", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "floor_id", "space_number")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("spaces").delete()
    }
}

import Fluent
import struct Foundation.Date
import struct Foundation.UUID

final class Garage: Model, @unchecked Sendable {
    static let schema = "garages"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Children(for: \.$garage)
    var floors: [Floor]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }

    func toDTO(floors: [FloorDTO]) -> GarageDTO {
        .init(
            id: self.id,
            name: self.name,
            floors: floors,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

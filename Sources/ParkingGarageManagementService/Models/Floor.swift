import Fluent
import struct Foundation.Date
import struct Foundation.UUID

final class Floor: Model, @unchecked Sendable {
    static let schema = "floors"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "floor_number")
    var floorNumber: String

    @Parent(key: "garage_id")
    var garage: Garage

    @Children(for: \.$floor)
    var parkingSpaces: [Space]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, floorNumber: String, garageID: Garage.IDValue) {
        self.id = id
        self.floorNumber = floorNumber
        self.$garage.id = garageID
    }

    func toDTO(spaces: [SpaceDTO]) -> FloorDTO {
        .init(
            id: self.id,
            floorNumber: self.floorNumber,
            parkingSpaces: spaces,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

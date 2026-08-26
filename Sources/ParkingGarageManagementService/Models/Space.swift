import Fluent
import struct Foundation.Date
import struct Foundation.UUID

final class Space: Model, @unchecked Sendable {
    static let schema = "spaces"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "space_number")
    var spaceNumber: Int

    @Field(key: "available")
    var available: Bool

    @Parent(key: "floor_id")
    var floor: Floor

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, spaceNumber: Int, available: Bool = true, floorID: Floor.IDValue) {
        self.id = id
        self.spaceNumber = spaceNumber
        self.available = available
        self.$floor.id = floorID
    }

    func toDTO() -> SpaceDTO {
        .init(
            id: self.id,
            spaceNumber: self.spaceNumber,
            available: self.available,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

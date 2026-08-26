import Fluent
import Vapor

struct FloorDTO: Content {
    var id: UUID?
    var floorNumber: String
    var parkingSpaces: [SpaceDTO]
    var createdAt: Date?
    var updatedAt: Date?
}

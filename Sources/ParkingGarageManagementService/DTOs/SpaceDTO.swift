import Fluent
import Vapor

struct SpaceDTO: Content {
    var id: UUID?
    var spaceNumber: Int
    var available: Bool
    var createdAt: Date?
    var updatedAt: Date?
}

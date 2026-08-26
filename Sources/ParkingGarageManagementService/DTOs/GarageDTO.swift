import Fluent
import Vapor

struct GarageDTO: Content {
    var id: UUID?
    var name: String
    var floors: [FloorDTO]
    var createdAt: Date?
    var updatedAt: Date?
}

/// Request body for creating a garage. The caller specifies the garage name and, for each
/// floor, only how many spaces it has - `floors.count` determines the number of floors, and
/// floor/space numbers are assigned by the service (e.g. "f1"/"f2", 1001-1003, 2001-2002, ...).
struct CreateGarageRequestDTO: Content {
    var name: String
    var floors: [CreateFloorRequestDTO]
}

struct CreateFloorRequestDTO: Content {
    var numberOfSpaces: Int
}

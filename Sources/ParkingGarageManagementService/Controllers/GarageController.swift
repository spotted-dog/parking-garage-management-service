import Fluent
import Vapor

struct GarageController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let garages = routes.grouped("garages")

        garages.get(use: self.index)
        garages.post(use: self.create)
        garages.get("new", use: self.newForm)
    }

    @Sendable
    func newForm(req: Request) async throws -> View {
        try await req.view.render("CreateGarage")
    }

    @Sendable
    func index(req: Request) async throws -> [GarageDTO] {
        let garages = try await Garage.query(on: req.db)
            .with(\.$floors) { $0.with(\.$parkingSpaces) }
            .all()

        return garages.map { garage in
            garage.toDTO(floors: garage.floors.map { floor in
                floor.toDTO(spaces: floor.parkingSpaces.map { $0.toDTO() })
            })
        }
    }

    @Sendable
    func create(req: Request) async throws -> GarageDTO {
        let request = try req.content.decode(CreateGarageRequestDTO.self)

        guard !request.name.isEmpty else {
            throw Abort(.badRequest, reason: "Garage name must not be empty.")
        }
        guard !request.floors.isEmpty else {
            throw Abort(.badRequest, reason: "A garage must have at least one floor.")
        }
        guard request.floors.allSatisfy({ $0.numberOfSpaces > 0 }) else {
            throw Abort(.badRequest, reason: "Each floor must have at least one space.")
        }

        let garage = Garage(name: request.name)

        let floorDTOs = try await req.db.transaction { database -> [FloorDTO] in
            try await garage.save(on: database)

            var floorDTOs: [FloorDTO] = []
            for (index, floorRequest) in request.floors.enumerated() {
                let floorNumber = "f\(index + 1)"
                let floor = Floor(floorNumber: floorNumber, garageID: try garage.requireID())
                try await floor.save(on: database)

                let floorID = try floor.requireID()
                let spaces = (1...floorRequest.numberOfSpaces).map { spaceIndex in
                    Space(spaceNumber: (index + 1) * 1000 + spaceIndex, floorID: floorID)
                }
                try await spaces.create(on: database)

                floorDTOs.append(floor.toDTO(spaces: spaces.map { $0.toDTO() }))
            }
            return floorDTOs
        }

        return garage.toDTO(floors: floorDTOs)
    }
}

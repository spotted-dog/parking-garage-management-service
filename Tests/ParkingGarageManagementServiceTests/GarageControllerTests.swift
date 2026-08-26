@testable import ParkingGarageManagementService
import VaporTesting
import Testing
import Fluent

/// Kept in the same suite as `ParkingGarageManagementServiceTests` (via extension, not a new
/// `@Suite`) so its tests run serially against the shared test database - see the note on
/// `withApp` for why a second suite would race migrations against these tests.
extension ParkingGarageManagementServiceTests {
    @Test("Creating a garage assigns floor/space numbers and persists the full hierarchy")
    func createGarageWithMultipleFloors() async throws {
        try await withApp { app in
            let request = CreateGarageRequestDTO(
                name: "Downtown Garage",
                floors: [
                    CreateFloorRequestDTO(numberOfSpaces: 3),
                    CreateFloorRequestDTO(numberOfSpaces: 2)
                ]
            )

            try await app.testing().test(.POST, "garages", beforeRequest: { req in
                try req.content.encode(request)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)

                let dto = try res.content.decode(GarageDTO.self)
                #expect(dto.name == "Downtown Garage")
                #expect(dto.floors.count == 2)

                let firstFloor = try #require(dto.floors.first(where: { $0.floorNumber == "f1" }))
                #expect(firstFloor.parkingSpaces.map(\.spaceNumber).sorted() == [1001, 1002, 1003])
                #expect(firstFloor.parkingSpaces.allSatisfy { $0.available })

                let secondFloor = try #require(dto.floors.first(where: { $0.floorNumber == "f2" }))
                #expect(secondFloor.parkingSpaces.map(\.spaceNumber).sorted() == [2001, 2002])
            })

            #expect(try await Garage.query(on: app.db).count() == 1)
            #expect(try await Floor.query(on: app.db).count() == 2)
            #expect(try await Space.query(on: app.db).count() == 5)
        }
    }

    @Test("Creating a garage with no floors is rejected")
    func createGarageWithNoFloorsIsRejected() async throws {
        try await withApp { app in
            let request = CreateGarageRequestDTO(name: "Empty Garage", floors: [])

            try await app.testing().test(.POST, "garages", beforeRequest: { req in
                try req.content.encode(request)
            }, afterResponse: { res async throws in
                #expect(res.status == .badRequest)
            })

            #expect(try await Garage.query(on: app.db).count() == 0)
        }
    }

    @Test("Creating a garage with a floor that has zero spaces is rejected")
    func createGarageWithZeroSpaceFloorIsRejected() async throws {
        try await withApp { app in
            let request = CreateGarageRequestDTO(
                name: "Bad Garage",
                floors: [CreateFloorRequestDTO(numberOfSpaces: 0)]
            )

            try await app.testing().test(.POST, "garages", beforeRequest: { req in
                try req.content.encode(request)
            }, afterResponse: { res async throws in
                #expect(res.status == .badRequest)
            })

            #expect(try await Garage.query(on: app.db).count() == 0)
        }
    }

    @Test("The new-garage form page renders")
    func newFormRenders() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "garages/new", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.headers.contentType?.description.contains("text/html") == true)
                #expect(res.body.string.contains("Create a Garage"))
            })
        }
    }

    @Test("Listing garages returns the persisted floor and space hierarchy")
    func indexReturnsPersistedGarages() async throws {
        try await withApp { app in
            let garage = Garage(name: "Existing Garage")
            try await garage.save(on: app.db)
            let floor = Floor(floorNumber: "f1", garageID: try garage.requireID())
            try await floor.save(on: app.db)
            let space = Space(spaceNumber: 1001, floorID: try floor.requireID())
            try await space.save(on: app.db)

            try await app.testing().test(.GET, "garages", afterResponse: { res async throws in
                #expect(res.status == .ok)
                let garages = try res.content.decode([GarageDTO].self)
                #expect(garages.count == 1)
                #expect(garages[0].floors.count == 1)
                #expect(garages[0].floors[0].parkingSpaces.count == 1)
                #expect(garages[0].floors[0].parkingSpaces[0].spaceNumber == 1001)
            })
        }
    }
}

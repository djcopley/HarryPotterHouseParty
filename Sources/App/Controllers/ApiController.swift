import Fluent
import Vapor

struct ApiController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes
            .grouped(APIKeyAuthenticator())
            .grouped(User.guardMiddleware())
            .grouped("api")

        let houses = api.grouped("houses")
        houses.get(use: getHouses)
        houses.group(":name") { house in
            house.get(use: getHouse)
            house.patch(use: updateHouseScore)
        }
    }

    func getHouses(req: Request) async throws -> [House] {
        try await House.query(on: req.db).all()
    }

    func getHouse(req: Request) async throws -> House {
        guard let houseName = req.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        guard let house = try await House.find(name: houseName, on: req.db) else {
            throw Abort(.notFound)
        }
        return house
    }

    func updateHouseScore(req: Request) async throws -> House {
        guard let houseName = req.parameters.get("name") else {
            throw Abort(.badRequest)
        }
        guard let house = try await House.find(name: houseName, on: req.db) else {
            throw Abort(.notFound)
        }
        let patchScore = try req.content.decode(PatchHouse.self)
        house.score = patchScore.score 
        try await house.update(on: req.db)
        return house
    }
}

// Structure of PATCH /api/houses/:name request.
fileprivate struct PatchHouse: Content {
    var score: Int
}

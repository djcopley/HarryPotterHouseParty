import Fluent
import Vapor

struct HouseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let houses = routes.grouped("house")

        houses.group(":name") { house in
            house.get(use: getHouse)
            house.patch(use: incrementHouseScore)
        }
    }

    func getHouse(req: Request) async throws -> View {
        guard let name = req.parameters.get("name") else {
            throw Abort(.badRequest, reason: "parameter 'name' required")
        }
        guard let house = try await House.find(name: name, on: req.db) else {
            throw Abort(.notFound, reason: "house '\(name)' not found")
        }
        return try await req.view.render("score", ScoreTemplateData(house: house))
    }

    func incrementHouseScore(req: Request) async throws -> Response {
        guard let name = req.parameters.get("name") else {
            throw Abort(.badRequest, reason: "parameter 'name' required")
        }
        guard let house = try await House.find(name: name, on: req.db) else {
            throw Abort(.notFound, reason: "house '\(name)' not found")
        }
        let incrementBy = try req.content.decode(IncrementHouseScoreRequest.self).incrementBy
        house.score += incrementBy
        try await house.update(on: req.db)
        try await SSEController.controller.sendEvent()
        return Response(status: .ok)
    }
}

private struct ScoreTemplateData: Codable {
    let house: House
}

// Structure of PATCH /houses/:name request.
private struct IncrementHouseScoreRequest: Content {
    var incrementBy: Int
}

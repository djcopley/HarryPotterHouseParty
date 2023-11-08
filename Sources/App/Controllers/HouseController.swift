import Fluent
import Vapor

struct HouseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let house = routes.grouped("house")
        house.get(":name", use: getHouse)
        house.patch(":name", use: updateHouse)
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

    func updateHouse(req: Request) async throws -> Response {
        guard let name = req.parameters.get("name") else {
            throw Abort(.badRequest, reason: "parameter 'name' required")
        }
        guard let house = try await House.find(name: name, on: req.db) else {
            throw Abort(.notFound, reason: "house '\(name)' not found")
        }
        let incrementBy = try req.content.decode(PatchHouse.self).incrementBy
        house.score += incrementBy
        try await house.update(on: req.db)
        try await SSEController.handler.sendEvent()
        return Response(status: .ok)
    }
}

fileprivate struct ScoreTemplateData: Codable {
    let house: House
}

// Structure of PATCH /houses/:name request.
fileprivate struct PatchHouse: Content {
    var incrementBy: Int
}
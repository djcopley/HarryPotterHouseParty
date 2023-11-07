import Fluent
import Vapor

struct HouseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let house = routes.grouped("house")
        house.get(":houseName", use: getHouse)
        house.patch(":houseName", use: updateHouse)
    }

    func getHouse(req: Request) async throws -> View {
        guard let houseName = req.parameters.get("houseName") else {
            throw Abort(.badRequest, reason: "parameter 'houseName' required")
        }
        guard let house = try await House.query(on: req.db).get(name: houseName) else {
            throw Abort(.notFound, reason: "house '\(houseName)' not found")
        }
        return try await req.view.render("house", HouseTemplateData(house: house, user: .init(loggedIn: true)))
    }

    func updateHouse(req: Request) async throws -> Response {
        guard let houseName = req.parameters.get("houseName") else {
            throw Abort(.badRequest, reason: "parameter 'houseName' required")
        }
        guard let house = try await House.query(on: req.db).get(name: houseName) else {
            throw Abort(.notFound, reason: "house '\(houseName)' not found")
        }
        house.score += try req.content.decode(UpdateHouseRequestContent.self).incrementBy
        try await house.update(on: req.db)
        try await SSEController.handler.sendEvent()
        return Response(status: .ok)
    }
}

extension QueryBuilder where Model == House {
    func get(name: String) async throws -> Model? {
        try await self.filter(\.$name == name).first()
    }
}

struct HouseTemplateData: Codable {
    let house: House
    let user: UserTemplate

    struct UserTemplate: Codable {
        let loggedIn: Bool
    }
}

struct UpdateHouseRequestContent: Content {
    var incrementBy: Int
}
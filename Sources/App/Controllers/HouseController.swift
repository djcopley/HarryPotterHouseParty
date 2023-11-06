import Fluent
import Vapor

struct HouseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let houses = routes.grouped("house")
        houses.get(":houseName", use: index)
        houses.patch(":houseName", use: updateHouse)
    }

    func index(req: Request) async throws -> View {
        guard let houseName = req.parameters.get("houseName"), let house = try await House.query(on: req.db).filter(\.$name == houseName).first() else {
            throw Abort(.notFound)
        }    
        return try await req.view.render("house", ["house": house])
    }

    func updateHouse(req: Request) async throws -> HTTPStatus {
        guard let houseName = req.parameters.get("houseName"), let house = try await House.query(on: req.db).filter(\.$name == houseName).first() else {
            throw Abort(.notFound)
        }
        return .noContent
    }

    func create(req: Request) async throws -> House {
        let house = try req.content.decode(House.self)
        try await house.save(on: req.db)
        return house
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let house = try await House.find(req.parameters.get("houseID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await house.delete(on: req.db)
        return .noContent
    }
}

import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        let houses = try await House.query(on: req.db).all()
        return try await req.view.render("index", ["houses": houses])
    }

    try app.register(collection: HouseController())
    try app.register(collection: ApiController())
}

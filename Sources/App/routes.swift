import Fluent
import Vapor

struct ScoresTemplate: Content {
    let user: UserTemplate?
    let houses: [House]
}

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        let houseOrder = ["gryffindor", "hufflepuff", "ravenclaw", "slytherin"]
        let houses = try await House
            .query(on: req.db)
            .all()
            .sorted { houseOrder.firstIndex(of: $0.name)! < houseOrder.firstIndex(of: $1.name)! }
        let user = req.auth.get(User.self)
        let context = ScoresTemplate(user: .init(from: user), houses: houses)
        return try await req.view.render("scores", context)
    }

    app.get("404") { req async throws -> View in
        try await req.view.render("404")
    }

    try app.register(collection: HouseController())
    try app.register(collection: HouseEventsController())
    try app.register(collection: UserController())
    try app.register(collection: ApiController())
}

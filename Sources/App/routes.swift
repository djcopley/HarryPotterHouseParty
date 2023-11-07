import Fluent
import Vapor

struct IndexTemplate: Codable {
    var houses: [House]
    var user: UserTemplate
    
    struct UserTemplate: Codable {
        var loggedIn: Bool
    }
}

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        let houses = try await House
            .query(on: req.db)
            .all()
            .sorted { $0.displayIndex < $1.displayIndex }
        return try await req.view.render("index", IndexTemplate(houses: houses, user: .init(loggedIn: true)))
    }

    app.get("house-events") { req in
        let response = Response()
        response.headers.add(name: .contentType, value: "text/event-stream")
        response.body = Response.Body(stream: { SSEController.handler.addClient(writer: $0)} )
        return response
    }

    try app.register(collection: HouseController())
    try app.register(collection: ApiController())
}

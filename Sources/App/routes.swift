import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        let houseOrder = ["gryffindor", "hufflepuff", "ravenclaw", "slytherin"]
        let houses = try await House
            .query(on: req.db)
            .all()
            .sorted { houseOrder.firstIndex(of: $0.name)! < houseOrder.firstIndex(of: $1.name)! }
        return try await req.view.render("index", IndexTemplateData(houses: houses, user: .init(loggedIn: true)))
    }

    app.get("login") { req async throws -> View in
        try await req.view.render("login")
    }

    app.post("login") { req async throws -> HTTPStatus in
        print(req.auth)
        return .accepted
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

fileprivate struct IndexTemplateData: Codable {
    var houses: [House]
    var user: UserTemplate
    
    struct UserTemplate: Codable {
        var loggedIn: Bool
    }
}
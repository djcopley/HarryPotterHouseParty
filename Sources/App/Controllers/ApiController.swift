import Fluent
import Vapor

struct ApiController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes
                                    .grouped("api")
                                    .grouped(User.credentialsAuthenticator())

        api.get("login") { req async throws -> View in
            try await req.view.render("login")
        }
        api.post("login") { req async throws -> HTTPStatus in
            print(req.auth)
            return .accepted
        }
        api.get(use: index)
    }

    func index(req: Request) async -> HTTPStatus {
        return .notImplemented
    }
}

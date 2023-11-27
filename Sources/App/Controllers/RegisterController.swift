import Vapor

struct CreateUserRequest: Content {
    let username: String
    let newPassword: String
    let confirmPassword: String
}

struct RegisterTemplate: Content {
    let user: UserTemplate?
}

final class RegisterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Redirect authenticated users back to the index
        let unauthenticated = routes.grouped(User.redirectAuthenticatedMiddleware(path: "/"))

        unauthenticated.group("register") { register in
            register.get(use: registerPage)
            register.post(use: createUser)
        }
    }

    // MARK - Register
    func registerPage(req: Request) async throws -> View {
        let context = RegisterTemplate(user: nil)
        return try await req.view.render("register", context)
    }

    func createUser(req: Request) async throws -> Response {
        let newUserInfo = try req.content.decode(CreateUserRequest.self)
        let house = try await House.find(name: "gryffindor", on: req.db)!
        guard newUserInfo.newPassword == newUserInfo.confirmPassword else {
            throw Abort(.badRequest)
        }
        let user = User(
            username: newUserInfo.username, passwordHash: try Bcrypt.hash(newUserInfo.newPassword), houseID: house.id!)
        try await user.create(on: req.db)
        req.auth.login(user)
        return req.redirect(to: "/")
    }
}

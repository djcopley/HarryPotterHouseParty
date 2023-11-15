import Vapor

final class UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("register") { register in
            register.get(use: self.register)
            register.post(use: self.createUser)
        }

        routes.group("login") { login in
            login.get(use: self.index)
            login.post(use: self.login)
        }

        routes.group("logout") { logout in
            logout.get(use: self.logout)
        }

        routes.group("settings") { settings in
            settings.get(use: self.settings)
        }
    }

    func index(req: Request) async throws -> Response {
        guard !req.auth.has(User.self) else {
            return req.redirect(to: "/")
        }
        return try await req.view.render("login").encodeResponse(for: req)
    }

    func register(req: Request) async throws -> View {
        try await req.view.render("register")
    }

    func createUser(req: Request) async throws -> Response {
        guard let userData = req.parameters.get("foo") else {
            throw Abort(.badRequest)
        }
        return req.redirect(to: "/")
    }

    func login(req: Request) async throws -> Response {
        let credentials = try req.content.decode(UserLoginRequest.self)
        guard let user = try await User.find(username: credentials.username, on: req.db) else {
            return req.redirect(to: "/login?failed=true")
        }

        guard try user.verify(password: credentials.password) else {
            return req.redirect(to: "/login?failed=true")
        }

        req.auth.login(user)
        return req.redirect(to: "/")
    }

    func logout(req: Request) async throws -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }

    func settings(req: Request) async throws -> Response {
        guard let username = req.auth.get(User.self)?.username, let user = try await User.find(username: username, on: req.db) else {
            return req.redirect(to: "/login")
        }
        return try await req.view.render("settings", SettingsTemplate(user: user)).encodeResponse(for: req)
    }
}

fileprivate struct SettingsTemplate: Codable {
    let user: User
}

fileprivate struct IndexRequest: Content {
    let failed: Bool
}

fileprivate struct UserLoginRequest: Content {
    let username: String
    let password: String
}
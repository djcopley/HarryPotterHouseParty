import Vapor

final class LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("login") { login in
            login.get(use: self.index)
            login.post(use: self.login)
        }

        routes.group("logout") { logout in
            logout.get(use: self.logout)
        }
    }

    func index(req: Request) async throws -> View {
        try await req.view.render("login")
    }

    func login(req: Request) async throws -> Response { 
        let credentials = try req.content.decode(UserLoginRequest.self)
        guard let user = try await User.find(username: credentials.username, on: req.db) else {
            return req.redirect(to: "/login-failed")
        }

        guard try user.verify(password: credentials.password) else {
            return req.redirect(to: "/login-failed")
        }

        req.auth.login(user)
        return req.redirect(to: "/")
    }

    func logout(req: Request) async throws -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }
}

fileprivate struct UserLoginRequest: Content {
    let username: String
    let password: String
}
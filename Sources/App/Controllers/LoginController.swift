import Vapor

struct UserLoginRequest: Content {
    let username: String
    let password: String
}

struct LoginQueryParams: Content {
    let failed: Bool
}

final class LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Redirect authenticated users back to the index
        let login = routes.grouped(User.redirectAuthenticatedMiddleware(path: "/"))

        login.group("login") { login in
            login.get(use: index)
            login.post(use: performLogin)
        }

        routes.group("logout") { logout in
            logout.post(use: performLogout)
        }
    }

    // MARK - Login

    func index(req: Request) async throws -> View {
        let indexRequest = try? req.query.decode(LoginQueryParams.self)
        return try await req.view.render("login", indexRequest)
    }

    func performLogin(req: Request) async throws -> Response {
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

    // MARK - Logout

    func performLogout(req: Request) -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }
}

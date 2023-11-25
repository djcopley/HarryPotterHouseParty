import Vapor

struct UserLoginRequest: Content {
    let username: String
    let password: String
}

struct CreateUserRequest: Content {
    let username: String
    let newPassword: String
    let confirmPassword: String
}

struct LoginQueryParams: Content {
    let failed: Bool
}

struct UserTemplate: Content {
    let username: String
    let profilePicture: String

    init(username: String, profilePicture: String = "/images/dumbledore.jpeg") {
        self.username = username
        self.profilePicture = profilePicture
    }

    init?(from user: User?) {
        guard let user = user else {
            return nil
        }
        self.username = user.username
        self.profilePicture = "/images/dumbledore.jpeg"
    }
}

struct RegisterTemplate: Content {
    let user: UserTemplate?
}

struct SettingsTemplate: Content {
    let user: UserTemplate
}

final class UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Redirect authenticated users back to the index
        let unauthenticated = routes.grouped(User.redirectAuthenticatedMiddleware(path: "/"))
        
        unauthenticated.group("register") { register in
            register.get(use: registerPage)
            register.post(use: createUser)
        }

        unauthenticated.group("login") { login in
            login.get(use: loginPage)
            login.post(use: performLogin)
        }

        // Redirect unauthenticated users to the login page
        let authenticated = routes.grouped(User.redirectMiddleware(path: "/login"))

        authenticated.group("settings") { settings in
            settings.get(use: settingsPage)
        }
        
        routes.group("logout") { logout in
            logout.post(use: performLogout)
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
        let user = User(username: newUserInfo.username, passwordHash: try Bcrypt.hash(newUserInfo.newPassword), houseID: house.id!)
        try await user.create(on: req.db)
        req.auth.login(user)
        return req.redirect(to: "/")
    }

    // MARK - Login

    func loginPage(req: Request) async throws -> View {
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

    // MARK - User Settings

    func settingsPage(req: Request) async throws -> Response {
        guard let username = req.auth.get(User.self)?.username, let user = try await User.find(username: username, on: req.db) else {
            throw Abort(.internalServerError)
        }
        let context = SettingsTemplate(user: .init(username: user.username))
        return try await req.view.render("settings", context).encodeResponse(for: req)
    }
    
    // MARK - Logout

    func performLogout(req: Request) async throws -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }
}

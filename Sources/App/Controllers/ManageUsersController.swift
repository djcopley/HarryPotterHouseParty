import Vapor

struct ManageUsersTemplate: Content {
    let user: UserTemplate?
    let users: [User]

    struct User: Content {
        let username: String
        let role: String
    }
}

struct ManageUsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let manageUsers = routes.grouped("manage-users")
        manageUsers.get(use: index)
    }

    func index(_ req: Request) async throws -> View {
        let users =
            try await User
            .query(on: req.db)
            .all()
            .map { user in
                ManageUsersTemplate.User(username: user.username, role: user.role.displayName)
            }
        let user = UserTemplate(from: req.auth.get(User.self))
        let context = ManageUsersTemplate(user: user, users: users)
        return try await req.view.render("manage-users", context)
    }
}

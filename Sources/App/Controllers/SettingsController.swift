import Vapor

struct SettingsTemplate: Content {
    let user: UserTemplate
}

final class SettingsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Redirect unauthenticated users to the login page
        let authenticated = routes.grouped(User.redirectMiddleware(path: "/login"))

        authenticated.group("settings") { settings in
            settings.get(use: settingsPage)
        }
    }

    // MARK - User Settings

    func settingsPage(req: Request) async throws -> Response {
        guard let username = req.auth.get(User.self)?.username,
            let user = try await User.find(username: username, on: req.db)
        else {
            throw Abort(.badRequest)
        }
        let context = SettingsTemplate(user: .init(username: user.username))
        return try await req.view.render("settings", context).encodeResponse(for: req)
    }

}

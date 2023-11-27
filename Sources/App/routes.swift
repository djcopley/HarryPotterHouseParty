import Fluent
import Vapor

func routes(_ app: Application) throws {

    app.get("404") { req async throws -> View in
        try await req.view.render("404")
    }

    try app.register(collection: ScoresController())
    try app.register(collection: HouseEventsController())
    try app.register(collection: RegisterController())
    try app.register(collection: LoginController())
    try app.register(collection: SettingsController())
    try app.register(collection: ManageUsersController())
    try app.register(collection: ApiController())
}

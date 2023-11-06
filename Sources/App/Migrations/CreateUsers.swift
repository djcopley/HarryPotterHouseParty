import Fluent
import Vapor

struct CreateUsers: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("password_hash", .string, .required)
            .create()

        let admin = User(username: "admin", passwordHash: try Bcrypt.hash("admin"))
        try await admin.create(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}

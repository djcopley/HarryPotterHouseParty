import Fluent
import Vapor

struct CreateUsers: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("password_hash", .string, .required)
            .unique(on: "username", name: "no_duplicate_usernames")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}

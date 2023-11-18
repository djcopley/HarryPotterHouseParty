import Fluent
import Vapor

struct CreateUsersSchema: AsyncMigration {
    func prepare(on database: Database) async throws {
        let role = try await database.enum("role")
            .case("headmaster")
            .case("headOfHouse")
            .case("prefect")
            .case("student")
            .create()

        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("password_hash", .string, .required)
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("house_id", .uuid, .required, .references("houses", "id"))
            .field("role", role, .required)
            .unique(on: "username", name: "no_duplicate_usernames")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
        try await database.enum("role").delete()
    }
}

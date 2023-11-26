import Fluent
import Vapor

// TODO: Remove this and implement logic to create dumbledore on first user connection
struct CreateDumbledore: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        let gryffindor = try await House.find(name: "gryffindor", on: database)!
        let dumbledore = User(
            username: "dumbledore", passwordHash: try Bcrypt.hash("RonWeasley"), houseID: gryffindor.id!,
            role: .headmaster)
        try await dumbledore.create(on: database)
    }

    func revert(on database: FluentKit.Database) async throws {
        try await User.find(username: "dumbledore", on: database)!.delete(on: database)
    }
}

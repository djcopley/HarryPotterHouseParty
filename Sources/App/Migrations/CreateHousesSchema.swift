import Fluent

struct CreateHousesSchema: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("houses")
            .id()
            .field("name", .string, .required)
            .field("score", .int, .required)
            .unique(on: "name", name: "no_duplicate_houses")
            .create()
        }

    func revert(on database: Database) async throws {
        try await database.schema("houses").delete()
    }
}

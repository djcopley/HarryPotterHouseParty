import Fluent

struct CreateHouses: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("houses")
            .id()
            .field("name", .string, .required)
            .field("score", .int, .required)
            .create()

        let houses = [
            House(name: "gryffindor"),
            House(name: "hufflepuff"),
            House(name: "ravenclaw"),
            House(name: "slytherin")
        ]
        for house in houses { try await house.create(on: database) }
    }

    func revert(on database: Database) async throws {
        try await database.schema("houses").delete()
    }
}

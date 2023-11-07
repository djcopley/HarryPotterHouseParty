import Fluent

struct CreateHouses: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("houses")
            .id()
            .field("name", .string, .required)
            .field("score", .int, .required)
            .field("display_index", .int, .required)
            .create()

        let houses = [
            House(name: "gryffindor", displayIndex: 0),
            House(name: "hufflepuff", displayIndex: 1),
            House(name: "ravenclaw", displayIndex: 2),
            House(name: "slytherin", displayIndex: 3)
        ]
        for house in houses { try await house.create(on: database) }
    }

    func revert(on database: Database) async throws {
        try await database.schema("houses").delete()
    }
}

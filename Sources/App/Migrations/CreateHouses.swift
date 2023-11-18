import Fluent

struct CreateHouses: AsyncMigration {
    let houses = ["gryffindor", "hufflepuff", "ravenclaw", "slytherin"]

    func prepare(on database: Database) async throws {
        for house in houses { try await House(name: house).create(on: database) }
    }

    func revert(on database: Database) async throws {
        for house in houses { try await House.find(name: house, on: database)!.delete(on: database) }
    }
}

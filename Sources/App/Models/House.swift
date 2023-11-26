import Fluent
import Vapor

final class House: Model, Content {
    static let schema = "houses"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "score")
    var score: Int

    @Children(for: \.$house)
    var users: [User]

    init() {}

    init(id: UUID? = nil, name: String, score: Int = 0) {
        self.id = id
        self.name = name
        self.score = score
    }
}

extension House {
    static func find(name: String, on database: Database) async throws -> House? {
        try await House.query(on: database).filter(\.$name == name).first()
    }
}

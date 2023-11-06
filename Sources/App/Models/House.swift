import Fluent
import Vapor

/// Harry Potter House
final class House: Model, Content {
    static let schema = "houses"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "score")
    var score: Int

    init() { }

    init(id: UUID? = nil, name: String, score: Int = 0) {
        self.id = id
        self.name = name 
        self.score = score
    }
}

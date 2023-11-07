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

    @Field(key: "display_index")
    var displayIndex: Int

    init() { }

    init(id: UUID? = nil, name: String, displayIndex: Int, score: Int = 0) {
        self.id = id
        self.name = name 
        self.displayIndex = displayIndex
        self.score = score
    }
}

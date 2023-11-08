import Fluent
import Vapor

/// Harry Potter House
final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Parent(key: "house_id")
    var house: House

    @Enum(key: "role")
    var role: Role

    init() { }

    init(id: UUID? = nil, username: String, passwordHash: String, house: House, role: Role = .student) {
        self.id = id
        self.username = username 
        self.passwordHash = passwordHash
        self.house = house
        self.role = role
    }

    enum Role: String, Codable {
        case headMaster = "Headmaster"
        case headOfHouse = "Head of House"
        case prefect = "Prefect"
        case student = "Student"
    }
}

extension User: ModelCredentialsAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "password_hash")
    var passwordHash: String

    // @Parent(key: "house_id")
    // var house: House

    // @Enum(key: "role")
    // var role: Role

    init() { }

    init(id: UUID? = nil, username: String, passwordHash: String) {
    // , house: House, role: Role = .student) {
        self.id = id
        self.username = username 
        self.passwordHash = passwordHash
        // self.house = house
        // self.role = role
    }

    /// Enum describing the user permissions within the system.
    enum Role: String, Codable {
        /// Users with this role have complete access to all houses.
        case headmaster = "Headmaster"

        /// Users with this role have permission to alter the score of their own house and approve
        /// student score request changes.
        case headOfHouse = "Head of House"

        /// Users with this role have permission to alter their own house score.
        case prefect = "Prefect"

        /// Users with this role have permission to submit a score change request to be reviewed and
        /// approved by the `Head of House` or `Headmaster`.
        case student = "Student"
    }
}

extension User {
    static func find(username: String, on database: Database) async throws -> User? {
        try await User.query(on: database).filter(\.$username == username).first()
    }
}

extension User: ModelSessionAuthenticatable { }

extension User: ModelCredentialsAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

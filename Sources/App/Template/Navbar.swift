import Vapor

struct UserTemplate: Content {
    let username: String
    let profilePicture: String

    init(username: String, profilePicture: String = "/images/dumbledore.jpeg") {
        self.username = username
        self.profilePicture = profilePicture
    }

    init?(from user: User?) {
        guard let user = user else {
            return nil
        }
        self.username = user.username
        self.profilePicture = "/images/dumbledore.jpeg"
    }
}
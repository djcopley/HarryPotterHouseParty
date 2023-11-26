import Vapor

struct APIKeyAuthenticator: AsyncRequestAuthenticator {
    func authenticate(request: Request) async throws {

    }
}

struct APIKey: Content {
    let apiKey: String
}

import Vapor

struct EnsureUserRolesMiddleware: AsyncMiddleware {
    private let roles: [User.Role]
    
    init(roles: [User.Role]) {
        self.roles = roles
    }

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let user = request.auth.get(User.self), self.roles.contains(user.role) else {
            throw Abort(.forbidden)
        }
        return try await next.respond(to: request)
    }
}

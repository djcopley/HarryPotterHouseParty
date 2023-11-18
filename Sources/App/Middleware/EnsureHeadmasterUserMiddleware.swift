import Vapor

struct EnsureHeadmasterUserMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let user = request.auth.get(User.self), user.role == .headmaster else {
            throw Abort(.unauthorized)
        }
        return try await next.respond(to: request)
    }
}

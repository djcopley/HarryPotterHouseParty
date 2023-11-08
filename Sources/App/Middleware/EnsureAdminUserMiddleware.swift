import Vapor

struct EnsureAdminUserMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let user = request.auth.get(User.self), user.username == "admin" else {
            return request.redirect(to: "/login")
        }
        return try await next.respond(to: request)
    }
}

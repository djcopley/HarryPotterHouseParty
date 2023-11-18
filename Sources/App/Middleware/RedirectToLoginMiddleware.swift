import Vapor

// TODO
struct RedirectToLoginMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        return try await next.respond(to: request)
    }
}

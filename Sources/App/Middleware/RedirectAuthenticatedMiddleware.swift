import Vapor

final class RedirectAuthenticatedMiddleware<A>: Middleware
    where A: Authenticatable
{
    let makePath: @Sendable (Request) -> String
    
    @preconcurrency init(_ authenticatableType: A.Type = A.self, makePath: @Sendable @escaping (Request) -> String) {
        self.makePath = makePath
    }

    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if !request.auth.has(A.self) {
            return next.respond(to: request)
        }

        let redirect = request.redirect(to: self.makePath(request))
        return request.eventLoop.makeSucceededFuture(redirect)
    }
}

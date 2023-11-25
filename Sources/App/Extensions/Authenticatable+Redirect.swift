import Vapor

extension Authenticatable {
    /// Basic middleware to redirect authenticated requests to the supplied path
    ///
    /// - parameters:
    ///    - path: The path to redirect to if the request is not authenticated
    public static func redirectAuthenticatedMiddleware(path: String) -> Middleware {
        self.redirectAuthenticatedMiddleware(makePath: { _ in path })
    }
    
    /// Basic middleware to redirect authenticated requests to the supplied path
    ///
    /// - parameters:
    ///    - makePath: The closure that returns the redirect path based on the given `Request` object
    @preconcurrency public static func redirectAuthenticatedMiddleware(makePath: @Sendable @escaping (Request) -> String) -> Middleware {
        RedirectAuthenticatedMiddleware<Self>(Self.self, makePath: makePath)
    }
}

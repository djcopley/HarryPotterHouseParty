import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import Redis

public func configure(_ app: Application) async throws {
    // MARK - Middleware
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.sessions.configuration.cookieName = "hphp-session"
    app.sessions.use(.redis)
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(User.sessionAuthenticator())

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)

    // MARK - Database
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateHousesSchema())
    app.migrations.add(CreateHouses())
    app.migrations.add(CreateUsersSchema())
    app.migrations.add(CreateDumbledore())

    // MARK - Redis
    app.redis.configuration = try RedisConfiguration(hostname: "localhost")

    // MARK - Templating
    app.views.use(.leaf)

    // MARK - Routes
    try routes(app)
}

import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    var postgresConfiguration = SQLPostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault))
    )
    // Sets the Postgres search_path so tables resolve to DATABASE_SCHEMA instead of "public",
    // which the deployed database roles are not granted access to (see sql/database_setup.sql).
    postgresConfiguration.searchPath = Environment.get("DATABASE_SCHEMA").map { [$0] }

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: postgresConfiguration), as: .psql)

    app.migrations.add(CreateGarage())
    app.migrations.add(CreateFloor())
    app.migrations.add(CreateSpace())

    app.views.use(.leaf)

    // register routes
    try routes(app)
}

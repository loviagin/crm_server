import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "Jniu8udehbdu883hhheudhd8wegddw",
        database: Environment.get("DATABASE_NAME") ?? "crmdb",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateAccount())
    app.migrations.add(CreateTransaction())
    app.migrations.add(CreateLedgerEntry())
    app.migrations.add(CreateEmployee())
    app.migrations.add(CreatePayslip())
    app.migrations.add(CreateHMRCToken())
    app.migrations.add(CreateUserToken())
    app.migrations.add(CreateInviteCode())
    app.migrations.add(CreateEmployeeTeams())
    app.migrations.add(CreateEmployeeTeamMembers())
    
    try await app.autoMigrate()
    
    app.http.server.configuration.hostname = "0.0.0.0"
    app.logger.logLevel = .debug
    // register routes
    try routes(app)
}

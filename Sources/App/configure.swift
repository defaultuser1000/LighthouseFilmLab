import Leaf
import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
//    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
//    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
//    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
//    services.register(middlewares)
    
    try services.register(AuthenticationProvider())
    var middlewares = MiddlewareConfig.default()
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
//    let config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "azakrzhevskiy", database: "lighthouse", password: nil, transport: .cleartext)
    let config = PostgreSQLDatabaseConfig(url: "postgres://jksospvxgfvmqy:1ab1b512ef684bd976bd29b6d0a49daac97b30c6bb89775d92e4a503e802e58e@ec2-54-246-92-116.eu-west-1.compute.amazonaws.com:5432/dak5od9bde62sg")
    let postgres = PostgreSQLDatabase(config: config!)
    
    var databases = DatabasesConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)
    
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Order.self, database: .psql)
    migrations.add(model: OrderFilm.self, database: .psql)
    migrations.add(migration: AdminUser.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
}

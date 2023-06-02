import Vapor


@main
struct ComponentB {
    static func main() async throws {
        let env = try Environment.detect()
        
        let app = Application(env)
        defer { app.shutdown() }
        
        app.http.client.configuration.timeout = .init(connect: .seconds(60), read: .seconds(60))
        app.http.server.configuration.port = 3030
        
        try Routes().register(app: app)
        try app.run()
    }
}

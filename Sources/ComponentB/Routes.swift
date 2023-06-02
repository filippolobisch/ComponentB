import Foundation
import Vapor


struct Routes {
    let mainController = MainController()
    
    func register(app: Application) throws {
        app.get("", use: self.index)
        app.post("echo", use: self.echo)
        app.post("adapt", use: self.adapt)
        app.get("stress", use: self.stress)
        app.get("shutdown", use: self.shutdown)
    }
    
    func index(request: Request) async throws -> String {
        return "Welcome from Component B!"
    }
    
    func echo(request: Request) async throws -> String {
        if let body = request.body.string {
            return body
        }
        return ""
    }
    
    func adapt(request: Request) async throws -> Bool {
        guard let body = request.body.string else { return false }
        guard let intVal = Int(body), let component = Component(rawValue: intVal) else {
            return false
        }
        
        let result = try await mainController.adaptSystem(to: component)
        return result
    }
    
    func stress(request: Request) async throws -> Bool {
        try await mainController.constantTask()
        return true
    }
    
    func shutdown(request: Request) async throws -> Bool {
        exit(0)
    }
}

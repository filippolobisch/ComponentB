//
//  MainController.swift
//  
//
//  Created by Filippo Lobisch on 18.05.23.
//

import Foundation

struct MainController {
    
    let localManager = LocalManager()
    
    func adaptSystem(to component: Component) async throws -> Bool {
        let files = try await localManager.listFilesInResourcesDirectory()
        
        let result = try await withThrowingTaskGroup(of: Bool.self) { group in
            for (name, ext) in files {
                group.addTask {
                    return try await self.move(name: name, ext: ext, to: component)
                }
            }
            
            var results: [Bool] = []
            for try await result in group {
                results.append(result)
            }
            
            return results.filter{ $0 == true }.count == files.count
        }
        
        return result
    }
    
    private func move(name: String, ext: String, to component: Component) async throws -> Bool {
        let endpoint = "\(component.endpoint)/receiveFile"
        let fileData = try await localManager.get(contentsOf: name, withExtension: ext)
        
        let fileDataAsString = String(data: fileData, encoding: .utf8)
        let dictionary: [String: Any] = ["fileData": fileDataAsString!, "name": name, "ext": ext]
        
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        let result = try await NetworkManager.shared.send(data: data, to: endpoint)
        return result
    }
    
    func constantTask() async throws {
        let files = try await localManager.listFilesInResourcesDirectory()
        try await withThrowingTaskGroup(of: Void.self) { group in
            for (name, ext) in files {
                group.addTask {
                    _ = try await localManager.get(contentsOf: name, withExtension: ext)
                }
            }
            
            try await group.waitForAll()
        }
    }
}

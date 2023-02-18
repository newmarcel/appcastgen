//
//  Configuration.swift
//  Appcast
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation

public struct Configuration: Hashable, Codable {
    public static let defaultFileName = "appcast.json"
    
    public let title: String
    public let link: URL
    public let description: String
    
    public let versionsDirectory: String
    public let appcastFilename: String
}

public extension Configuration {
    enum ReadError: Error {
        case missingVersionsDirectory(expectedURL: URL)
    }
    
    init(_ fileURL: URL) throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let data = try Data(contentsOf: fileURL)
        self = try decoder.decode(type(of: self), from: data)
        
        try self.verifyVersionsDirectoryExists(relativeTo: fileURL)
    }
}

extension Configuration {
    func createVersionsDirectoryURL(relativeTo fileURL: URL) throws -> URL {
        let versionsDirectoryURL: URL
        if #available(macOS 13.0, *) {
            versionsDirectoryURL = fileURL.deletingLastPathComponent().appending(component: self.versionsDirectory)
        } else {
            versionsDirectoryURL = fileURL.deletingLastPathComponent().appendingPathComponent(self.versionsDirectory)
        }
        return versionsDirectoryURL
    }
}

private extension Configuration {
    func verifyVersionsDirectoryExists(relativeTo fileURL: URL) throws {
        let versionsDirectoryURL = try self.createVersionsDirectoryURL(relativeTo: fileURL)
        
        guard FileManager.default.fileExists(atPath: versionsDirectoryURL.path) else {
            throw ReadError.missingVersionsDirectory(expectedURL: versionsDirectoryURL)
        }
    }
}

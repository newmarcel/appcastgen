//
//  Version.swift
//  Appcast
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation

public struct Version: Hashable, Codable {
    public let date: Date // "2014-11-13 11:11:00"
    public let fileUrl: URL
    public let fileLength: Int
    public let fileVersion: String
    public let fileShortVersion: String
    
    public var minimumSystemVersion: String?
    public var isPrerelease: Bool?
}

public extension Version {
    init(fileURL: URL) throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(.simple)
        
        let data = try Data(contentsOf: fileURL)
        self = try decoder.decode(type(of: self), from: data)
    }
}

//
//  Appcast.swift
//  Appcast
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation

public struct Appcast {
    public let fileURL: URL
    public let configuration: Configuration
    public let channel: Channel
}

public extension Appcast {
    enum ReadError: Error {
        case missingConfiguration(fileURL: URL)
    }
    
    init(fileURL: URL) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw ReadError.missingConfiguration(fileURL: fileURL)
        }
        
        let configuration = try Configuration(fileURL)
        let versionDirectoryURL = try configuration.createVersionsDirectoryURL(relativeTo: fileURL)
        let versionFileSets = try VersionFileSet.readAll(fromDirectoryAt: versionDirectoryURL)
        let versionItems = try versionFileSets
            .map(Channel.VersionItem.init(_:))
            .sorted(by: { $0.publishDate > $1.publishDate })
        let channel = Channel(
            title: configuration.title,
            link: configuration.link,
            description: configuration.description,
            versionItems: versionItems
        )
        
        self.fileURL = fileURL
        self.configuration = configuration
        self.channel = channel
        
        print("Using configuration file '\(self.fileURL.path)'…")
        print("\(configuration.title)\n\(configuration.description)\n")
    }
}

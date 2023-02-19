//
//  AppcastGen.swift
//  appcastgen
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation
import ArgumentParser
import Appcast

@main
struct AppcastGen: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "appcastgen",
        abstract: "appcastgen creates an 'appcast.xml' file from version JSON and Markdown file pairs."
    )
    
    @Argument
    var configurationFilePath: String = Configuration.defaultFileName
    
    @Flag(
        name: [.customShort("c"), .customLong("channels")],
        inversion: .prefixedEnableDisable,
        help: "Add a prerelease channel tag to a version instead of creating multiple 'appcast.xml' files."
    )
    var isUseChannelsEnabled: Bool = false
    
    mutating func run() throws {        
        let appcast = try Appcast(fileURL: self.configurationFileURL)
        try appcast.write()
    }
}

private extension AppcastGen {
    var configurationFileURL: URL {
        let expandedPath = self.configurationFilePath.expandingTilde
        let workingDirectoryURL = Process().currentDirectoryURL
        
        let url: URL
        if #available(macOS 13.0, *) {
            url = URL(filePath: expandedPath, directoryHint: .notDirectory, relativeTo: workingDirectoryURL)
        } else {
            url = URL(fileURLWithPath: expandedPath, isDirectory: false, relativeTo: workingDirectoryURL)
        }
        return url
    }
}

private extension String {
    var expandingTilde: String {
        guard self.hasPrefix("~") else { return self }
        
        let unprefixedPath: Substring
        if self.hasPrefix("~/") {
            unprefixedPath = self.dropFirst(2)
        } else {
            unprefixedPath = self.dropFirst()
        }
        
        let homePath: String = {
            let home = FileManager.default.homeDirectoryForCurrentUser
            if #available(macOS 13.0, *) {
                return home.path(percentEncoded: false)
            } else {
                return home.path
            }
        }()
        
        return homePath + unprefixedPath
    }
}

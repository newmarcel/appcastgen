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
    @Argument var configurationFilePath: String = Configuration.defaultFileName
    
    mutating func run() throws {        
        let appcast = try Appcast(fileURL: self.configurationFileURL)
        try appcast.write()
    }
}

private extension AppcastGen {
    var configurationFileURL: URL {
        guard let workingDirectoryURL = Process().currentDirectoryURL else {
            fatalError("Failed to retrieve current working directory.")
        }
        if #available(macOS 13.0, *) {
            return workingDirectoryURL.appending(component: self.configurationFilePath, directoryHint: .notDirectory)
        } else {
            return workingDirectoryURL.appendingPathComponent(self.configurationFilePath)
        }
    }
}

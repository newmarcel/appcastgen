//
//  Appcast+XML.swift
//  Appcast
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation

public extension Appcast {
    func write() throws {
        let baseFileName = self.configuration.appcastFilename
        
        // Stable Appcast
        let stableContents = self.createLines(for: .stable).joinedLines
        try self.writeContents(stableContents, toFileWithName: baseFileName)
        
        // PreRelease Appcast
        if self.hasPreReleaseItems {
            let preReleaseContents = self.createLines(for: .preRelease).joinedLines
            try self.writeContents(preReleaseContents, toFileWithName: "prerelease-\(baseFileName)")
        }
    }
}

private extension Appcast {
    var hasPreReleaseItems: Bool {
        !self.channel.versionItems.filter { $0.release == .preRelease }.isEmpty
    }
    
    func createLines(for release: Channel.Release) -> [String] {
        self.channel.createLines(for: release).wrappedInRSSEnvelop()
    }
    
    func writeContents(_ contents: String, toFileWithName fileName: String) throws {
        let fileURL: URL = {
            if #available(macOS 13.0, *) {
                return self.fileURL.deletingLastPathComponent().appending(component: fileName, directoryHint: .notDirectory)
            } else {
                return self.fileURL.deletingLastPathComponent().appendingPathComponent(fileName)
            }
        }()
        
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        print("Finished writing '\(fileURL.path)'.")
    }
}

private extension Channel {
    func createLines(for release: Release) -> [String] {
        var lines: [String] = [
            XML.tag(name: "title", self.title),
            XML.tag(name: "link", self.link.absoluteString),
            XML.tag(name: "description", self.description),
            XML.tag(name: "language", self.language),
        ]
        
        for item in self.versionItems where item.isContained(in: release) {
            lines.append(contentsOf: item.createLines())
        }
        
        return lines.wrapped(inTagWithName: "channel")
    }
}

private extension Channel.VersionItem {
    func isContained(in release: Channel.Release) -> Bool {
        switch release {
        case .stable where self.release == .stable:
            return true
        case .preRelease:
            return true
        default:
            return false
        }
    }
    
    func createLines() -> [String] {
        var lines: [String] = [
            XML.tag(name: "title", self.title.wrappedInCData),
            XML.tag(name: "description", self.description.wrappedInCData),
            XML.tag(name: "pubDate", self.publishDateString),
        ]
        if let minimumSystemVersion = self.minimumSystemVersion {
            lines.append(XML.tag(name: "sparkle:minimumSystemVersion", minimumSystemVersion))
        }
        lines.append(contentsOf: self.enclosure.createLines())
        return lines.wrapped(inTagWithName: "item")
    }
}

private extension Channel.Enclosure {
    func createLines() -> [String] {
        let attributes = "url=\"\(self.url.absoluteString)\" length=\"\(self.length)\" type=\"\(self.type)\" sparkle:version=\"\(self.version)\" sparkle:shortVersionString=\"\(self.shortVersion)\""
        
        return [
            "<enclosure \(attributes)>",
            "</enclosure>",
        ]
       }
}

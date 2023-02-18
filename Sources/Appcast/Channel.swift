//
//  Channel.swift
//  Appcast
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation

public struct Channel {
    public let title: String
    public let link: URL
    public let description: String
    public let language: String = "en"
    
    public var versionItems: [VersionItem] = []
}

public extension Channel {
    enum Release {
        case stable
        case preRelease
    }
    
    struct Enclosure {
        public let url: URL
        public let length: Int
        public let type: String = "application/octet-stream"
        public let version: String
        public let shortVersion: String
    }
    
    struct VersionItem {
        public let fileSet: VersionFileSet
        public let title: String
        public let description: String
        public let publishDate: Date
        public let minimumSystemVersion: String?
        public let enclosure: Enclosure
        public let release: Release
    }
}

public extension Channel.VersionItem {
    var publishDateString: String {
        DateFormatter.gmt.string(from: self.publishDate)
    }
    
    init(_ versionFileSet: VersionFileSet) throws {
        let (version, title, markdownContents) = try versionFileSet.readContents()
        
        self.fileSet = versionFileSet
        self.title = title
        self.description = markdownContents
        self.publishDate = version.date
        self.minimumSystemVersion = version.minimumSystemVersion
        
        self.enclosure = Channel.Enclosure(
            url: version.fileUrl,
            length: version.fileLength,
            version: version.fileVersion,
            shortVersion: version.fileShortVersion
        )
        
        self.release = version.isPrerelease.releaseValue
    }
}

private extension Optional where Wrapped == Bool {
    var releaseValue: Channel.Release {
        switch self {
        case .none:
            return .stable
        case .some(let value):
            switch value {
            case true:
                return .preRelease
            case false:
                return .stable
            }
        }
    }
}

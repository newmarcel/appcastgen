//
//  VersionFileSet.swift
//  Appcast
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation

public struct VersionFileSet {
    public let baseName: String
    public let jsonFileURL: URL
    public let markdownFileURL: URL
}

public extension VersionFileSet {
    enum ReadError: Error {
        case invalidVersionsDirectory
        case jsonMarkdownFileMismatch(fileName: String)
    }
    
    static func readAll(fromDirectoryAt directoryURL: URL) throws -> [VersionFileSet] {
        let fileManager = FileManager.default
        
        guard let enumerator = fileManager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
        ) else {
            throw ReadError.invalidVersionsDirectory
        }
        
        var jsonFiles: [String: URL] = [:]
        var markdownFiles: [String: URL] = [:]
        
        for itemURL in enumerator {
            guard let fileURL = itemURL as? URL, ["json", "md"].contains(fileURL.pathExtension) else {
                continue
            }
            let baseFileName = fileURL.deletingPathExtension().lastPathComponent
            
            switch fileURL.pathExtension {
            case "json":
                jsonFiles[baseFileName] = fileURL
            case "md":
                markdownFiles[baseFileName] = fileURL
            default:
                break
            }
        }
        
        return try jsonFiles.map { baseName, jsonFileURL in
            guard let markdownFileURL = markdownFiles[baseName] else {
                throw ReadError.jsonMarkdownFileMismatch(fileName: baseName)
            }
            return self.init(baseName: baseName, jsonFileURL: jsonFileURL, markdownFileURL: markdownFileURL)
        }
    }
    
    func readContents() throws -> (Version, title: String, contents: String) {
        let version = try Version(fileURL: self.jsonFileURL)
        
        let stringData = try Data(contentsOf: self.markdownFileURL)
        let string = String(data: stringData, encoding: .utf8) ?? ""
        let (title, contents) = extractTitleAndContentsFromMarkdown(rawContents: string)
        
        return (version, title, contents.convertFromMarkdownToHTML())
    }
}

private func extractTitleAndContentsFromMarkdown(rawContents: String) -> (title: String, contents: String) {
    var components = rawContents.components(separatedBy: .newlines)
    guard !components.isEmpty else { return ("", rawContents) }
    
    let title: String = {
        if let firstLine = components.first?.replacingOccurrences(of: "#", with: "") {
            components.removeFirst()
            return firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }()
    
    let remainder = components.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    
    return (title: title, contents: remainder)
}

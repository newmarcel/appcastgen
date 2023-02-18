//
//  XML.swift
//  Appcast
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation

enum XML {
    static let newline = "\n"
    static let tab = "\t"
    
    static func tag(name: String, _ value: String) -> String {
        "<\(name)>\(value)</\(name)>"
    }
}

extension String {
    var wrappedInCData: String {
        "<![CDATA[\(self)]]>"
    }
    
    func indented(by level: Int = 1) -> String {
        var output = ""
        for _ in 0..<level {
            output += XML.tab
        }
        return output + self
    }
}

extension Array where Element == String {
    var joinedLines: Element {
        self.joined(separator: XML.newline)
    }
    
    func indented(by level: Int = 1) -> Array<Element> {
        self.map { $0.indented(by: level) }
    }
    
    func wrapped(inTagWithName tagName: String, indentedBy level: Int = 1) -> Array<Element> {
        var lines: Array<Element> = []
        
        lines.append("<\(tagName)>")
        lines.append(contentsOf: self.indented(by: level))
        lines.append("</\(tagName)>")
        
        return lines
    }
    
    func wrappedInRSSEnvelop() -> Array<Element> {
        var lines: Array<Element> = [
            "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>",
            "<rss version=\"2.0\" xmlns:sparkle=\"http://www.andymatuschak.org/xml-namespaces/sparkle\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\">"
        ]
        lines.append(contentsOf: self.indented())
        lines.append("</rss>")
        return lines
    }
}

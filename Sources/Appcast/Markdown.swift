//
//  Markdown.swift
//  Appcast
//
//  Created by Marcel Dierkes on 17.02.23.
//

import Foundation
import Ink

extension String {
    func convertFromMarkdownToHTML() -> String {
        let parser = MarkdownParser()
        let result = parser.parse(self)
        return result.html
    }
}

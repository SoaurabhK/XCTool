//
//  ArgParser.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 09/08/20.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ArgParser {
    let arguments = CommandLine.arguments
    func value(for tag: String) -> String? {
        let index = arguments.firstIndex(of: tag)?.advanced(by: 1)
        guard let tagIndex = index, let value = arguments[safe: tagIndex] else {
            return nil
        }
        return value
    }
}




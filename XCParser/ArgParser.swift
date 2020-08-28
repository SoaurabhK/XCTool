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
    private static let arguments = CommandLine.arguments
    
    static func value(for tag: String) -> String? {
        let index = arguments.firstIndex(of: tag)?.advanced(by: 1)
        guard let tagIndex = index, let value = arguments[safe: tagIndex] else {
            return nil
        }
        return value
    }
    
    static func contains(tag: String) -> Bool {
        return arguments.contains(tag)
    }
}

struct LaunchArgs {
    let project: String
    let scheme: String
    let destination: String
}

extension ArgParser {
    static var launchArgs: LaunchArgs? {
        let project = Self.value(for: "-project")
        let scheme = Self.value(for: "-scheme")
        let destination = Self.value(for: "-destination")
        
        guard let projPath = project, let schemeName = scheme, let runDestination = destination else {
            return nil
        }
        return LaunchArgs(project: projPath, scheme: schemeName, destination: runDestination)
    }
}



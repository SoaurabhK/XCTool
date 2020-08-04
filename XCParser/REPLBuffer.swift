//
//  StreamReader.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 04/08/20.
//

import Foundation

struct REPLBuffer {
    private var buffer = Data()
    private let delimData = String("\n").data(using: .utf8)!
    
    mutating func append(_ data: Data) -> String? {
        buffer.append(data)
        return getLine()
    }
    
    mutating func outstandingText() -> [String]? {
        defer {
            buffer.removeAll()
            buffer.count = 0
        }
        guard buffer.count > 0 else {
            return nil
        }
        
        var result = [String]()
        while let line = getLine() {
            result.append(line)
        }
        
        // Get remaining buffer text(if any)
        guard buffer.count > 0, let text = String(data: buffer, encoding: .utf8) else {
            return result
        }
        result.append(text)
        
        return result
    }
    
    private mutating func getLine() -> String? {
        guard let range = buffer.range(of: delimData) else { return nil }
    
        //Convert complete line (excluding the delimiter) to a string:
        let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: .utf8)
        //Remove line (and the delimiter) from the buffer:
        buffer.removeSubrange(0..<range.upperBound)
        return line
    }
}

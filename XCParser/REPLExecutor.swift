//
//  REPLOutputDecoder.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 08/08/20.
//

import Foundation

struct REPLExecutor {
    static func exec<T: Decodable>(command: REPLCommand, for type: T.Type) -> T? {
        let data = command.run()
        guard data.exitStatus == 0 else { return nil }
        guard let outData = data.result?.data(using: .utf8) else { return nil }
        let result = try? JSONDecoder().decode(T.self, from: outData)
        return result
    }
    
    static func execTest(_ command: REPLCommand) -> String? {
        var xcresultPath: String?
        command.run { (lines) in
            lines?.forEach({ print($0) })
            xcresultPath = lines?.first(where: { $0.hasSuffix(".xcresult")})?.trimmingCharacters(in: CharacterSet(charactersIn: "\t"))
        }
        return xcresultPath
    }
}

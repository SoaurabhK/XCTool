//
//  REPLOutputDecoder.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 08/08/20.
//

import Foundation

struct REPLExecutor {
    let command: REPLCommand
    
    func exec<T: Decodable>(for type: T.Type) -> T? {
        let data = command.run()
        guard data.exitStatus == 0 else { return nil }
        guard let outData = data.result else { return nil }
        let result = autoreleasepool { () -> T? in
            try? JSONDecoder().decode(T.self, from: outData)
        }
        return result
    }
    
    func execTest(verbose isVerbose: Bool = false) -> String? {
        var xcresultPath: String?
        command.run { (lines) in
            if isVerbose { lines?.forEach{ print($0) } }
            xcresultPath = lines?.first(where: { $0.hasSuffix(".xcresult")})
        }
        return xcresultPath?.trimmingCharacters(in: CharacterSet(charactersIn: "\t"))
    }
}

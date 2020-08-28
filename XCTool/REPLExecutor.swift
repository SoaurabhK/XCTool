//
//  REPLOutputDecoder.swift
//  XCTool
//
//  Created by Soaurabh Kakkar on 08/08/20.
//

import Foundation

struct REPLExecutor {
    let command: REPLCommand
    
    func exec<T: Decodable>(for type: T.Type) -> T? {
        let data = command.run()
        guard data.exitStatus == EXIT_SUCCESS else { return nil }
        guard let outData = data.result else { return nil }
        let result = autoreleasepool { () -> T? in
            try? JSONDecoder().decode(T.self, from: outData)
        }
        return result
    }
    
    func exec(outputChunk: @escaping ([String]?) -> Void) -> Int32 {
        command.run { (lines) in
            outputChunk(lines)
        }
    }
}

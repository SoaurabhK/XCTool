//
//  main.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 01/08/20.
//

import Foundation

typealias Executor = REPLExecutor
typealias Command = REPLCommand

let executor = Executor(command: Command(launchPath: Constants.xcodebuildExecPath, arguments: Constants.xcodebuildExecArg))
let resultBundle = executor.execTest()

guard let xcresultBundle = resultBundle, FileManager.default.fileExists(atPath: xcresultBundle) else { print("Couldn't find .xcresult bundle"); exit(-1) }
print("xcresultBundle: \(xcresultBundle)")

let parser = XCParser(xcresultBundle: xcresultBundle)
parser.testSummaries().forEach({ dump($0) })

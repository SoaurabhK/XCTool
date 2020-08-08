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
let resultFile = executor.execTest()

guard let xcresultFile = resultFile, FileManager.default.fileExists(atPath: xcresultFile) else { print("Couldn't find .xcresult file"); exit(-1) }
print("xcresultFile: \(xcresultFile)")

let parser = XCParser(xcresultFile: xcresultFile)
parser.testSummaries().forEach({ dump($0) })

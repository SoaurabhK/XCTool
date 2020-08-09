//
//  main.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 01/08/20.
//

import Foundation

typealias Executor = REPLExecutor
typealias Command = REPLCommand

let argParser = ArgParser()
let project = argParser.value(for: "-project")
let scheme = argParser.value(for: "-scheme")
let destination = argParser.value(for: "-destination")
guard let projPath = project, let schemeName = scheme, let runDestination = destination else {
    print("Usage: ./XCParser -project <project-path> -scheme <scheme-name> -destination <destination(platform,name,OS(for simulator)>")
    exit(-1)
}

let executor = Executor(command: Command(launchPath: Constants.xcodebuildExecPath, arguments: ["-project", projPath, "-scheme", schemeName, "-destination", runDestination, "test"]))
let resultBundle = executor.execTest()

guard let xcresultBundle = resultBundle, FileManager.default.fileExists(atPath: xcresultBundle) else { print("Couldn't find .xcresult bundle"); exit(-1) }

let parser = XCParser(xcresultBundle: xcresultBundle)
parser.testSummaries().forEach({ dump($0) })

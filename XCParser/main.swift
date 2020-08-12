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

let bundle = ResultBundle(xcodeprojPath: projPath)
guard let xcresultBundle = bundle.projRelativePath else {
    print("Couldn't get a valid .xcresult bundlePath")
    exit(-1)
}

let executor: Executor = Executor(command: Command(launchPath: Constants.xcodebuildExecPath, arguments: ["test", "-project", projPath, "-scheme", schemeName, "-destination", runDestination, "-resultBundlePath", xcresultBundle]))

let isVerbose = argParser.contains(tag: "-verbose")
let testStatus = executor.execTest(verbose: isVerbose)

guard testStatus == EXIT_SUCCESS else { print("Test Execution Failed!"); exit(-1) }

let parser = XCParser(xcresultBundle: xcresultBundle)
parser.testSummaries().forEach({ dump($0) })

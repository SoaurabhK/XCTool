//
//  main.swift
//  XCTool
//
//  Created by Soaurabh Kakkar on 01/08/20.
//
// NOTE: We can also split the workflow of building and testing and if we want to pass build artifacts & xctestrun file to other machines then we can get BUILD_DIR from project's build-settings: https://stackoverflow.com/a/47019252

import Foundation

typealias Executor = REPLExecutor
typealias Command = REPLCommand

let arguments = ArgParser.launchArgs
guard let launchArgs = arguments else {
    print("Usage: ./XCTool -workspace <workspace-path> -project <project-path> -scheme <scheme-name> -destination <destination(platform,name,OS(for simulator)>")
    exit(-1)
}

let bundle: ResultBundle = ResultBundle(xcodeprojPath: launchArgs.project)
guard let xcresultBundle = bundle.projRelativePath else {
    print("Couldn't get a valid .xcresult bundlePath")
    exit(-1)
}

let executor: Executor = Executor(command: Command(launchPath: Constants.xcodebuildExecPath, arguments: ["test", "-workspace", launchArgs.workspace, "-scheme", launchArgs.scheme, "-destination", launchArgs.destination, "-resultBundlePath", xcresultBundle]))
let testStatus = executor.exec{ $0?.forEach { print($0) } }

let parser: XCTool = XCTool(xcresultBundle: xcresultBundle)
let testSummaries = parser.testSummaries()

guard testStatus != EXIT_SUCCESS else {
    testSummaries.forEach{ dump($0) }
    exit(0)
}
print("Test execution failed, retrying failed tests!")

let failure = TestFailure(testSummaries: testSummaries, maxRetries: Constants.maxRetries, bundle: bundle, launchArgs: launchArgs)
let (retryStatus, finalSummaries) = failure.retry()

guard retryStatus != EXIT_SUCCESS else {
    finalSummaries.forEach{ dump($0) }
    exit(0)
}
print("FATAL: Retry test execution failed, please investigate!")

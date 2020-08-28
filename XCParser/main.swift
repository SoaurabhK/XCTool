//
//  main.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 01/08/20.
//
// NOTE: We can also split the workflow of building and testing and if we want to pass build artifacts & xctestrun file to other machines then we can get BUILD_DIR from project's build-settings: https://stackoverflow.com/a/47019252

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

let testStatus = executor.exec{ $0?.forEach { print($0) } }

let parser = XCParser(xcresultBundle: xcresultBundle)
let testSummaries = parser.testSummaries()

if testStatus == EXIT_SUCCESS {
    testSummaries.forEach{ dump($0) }
} else {
    print("Test execution failed, retrying failed tests!")
    let (successTests, failedTests) = testSummaries.reduce(([TestSummary](), [TestSummary]())) { (accumulator, testSummary) -> ([TestSummary], [TestSummary]) in
        let (success, fail) = accumulator
        if testSummary.testStatus == "Success" {
            return (success + [testSummary], fail)
        } else {
            return (success, fail + [testSummary])
        }
    }
    let retryResult = retryFailedTests(failedTests, maxTries: 3)
    guard retryResult.status == EXIT_SUCCESS else {
        print("FATAL: Retry test execution failed, please investigate!")
        exit(-1)
    }
    let finalTestSummaries = successTests + retryResult.testSummaries
    finalTestSummaries.forEach{ dump($0) }
}

func retryFailedTests(_ tests: [TestSummary], maxTries: Int) -> (status: Int32, testSummaries: [TestSummary]) {
    for iteration in 1...maxTries {
        guard let retryBundlePath = bundle.retryPath(forIteration: iteration) else { continue }
        
        let failedTestsArgs = tests.map { testSummary -> String in
            let testingOption = String("\(testSummary.targetName)/\(testSummary.identifier)")
            return "-only-testing:\(testingOption)"
        }
        
        let executor: Executor = Executor(command: Command(launchPath: Constants.xcodebuildExecPath, arguments: ["test", "-project", projPath, "-scheme", schemeName, "-destination", runDestination, "-resultBundlePath", retryBundlePath] + failedTestsArgs))
        let testStatus = executor.exec{ $0?.forEach { print($0) } }
        
        guard testStatus == EXIT_SUCCESS else {
            print("Test execution failed for retry-iteration: \(iteration) with result-bundle: \(retryBundlePath)")
            continue
        }
        
        let parser = XCParser(xcresultBundle: retryBundlePath)
        let testSummaries = parser.testSummaries()
        return (testStatus, testSummaries)
    }
    return (EXIT_FAILURE, [])
}

//
//  RetryFailures.swift
//  XCTool
//
//  Created by Soaurabh Kakkar on 28/08/20.
//

import Foundation

struct TestFailure {
    let testSummaries: [TestSummary]
    let maxRetries: Int
    let bundle: ResultBundle
    let launchArgs: LaunchArgs
    
    func retry() -> (status: Int32, testSummaries: [TestSummary]) {
        let (successSummaries, failedSummaries) = self.filterSummaries
        let failedTestsArgs = failedSummaries.map(testArgsForSummary)
        
        for iteration in 1...maxRetries {
            guard let retryBundlePath = bundle.retryPath(forIteration: iteration) else { continue }
            
            let executor = Executor(command: Command(launchPath: Constants.xcodebuildExecPath, arguments: ["test", "-project", launchArgs.project, "-scheme", launchArgs.scheme, "-destination", launchArgs.destination, "-resultBundlePath", retryBundlePath] + failedTestsArgs))
            let testStatus = executor.exec{ $0?.forEach { print($0) } }
            
            guard testStatus == EXIT_SUCCESS else {
                print("Test execution failed for retry-iteration: \(iteration) with result-bundle: \(retryBundlePath)")
                continue
            }
            
            let parser = XCTool(xcresultBundle: retryBundlePath)
            let retrySummaries = parser.testSummaries()
            return (testStatus, successSummaries + retrySummaries)
        }
        return (EXIT_FAILURE, [])
    }
    
    private func testArgsForSummary(_ testSummary: TestSummary) -> String {
        let testingOption = "\(testSummary.targetName)/\(testSummary.identifier)"
        return "-only-testing:\(testingOption)"
    }
    
    private var filterSummaries: (success: [TestSummary], failures: [TestSummary]) {
        testSummaries.reduce(([TestSummary](), [TestSummary]())) { (accumulator, testSummary) -> ([TestSummary], [TestSummary]) in
            let (success, failures) = accumulator
            if testSummary.testStatus.caseInsensitiveCompare("Success") == .orderedSame {
                return (success + [testSummary], failures)
            } else {
                return (success, failures + [testSummary])
            }
        }
    }
}

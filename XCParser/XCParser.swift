//
//  TestSummaries.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 08/08/20.
//

import Foundation

struct XCParser {
    let xcresultBundle: String
    
    func testSummaries() -> [ActionTestSummary] {
        guard let testsRefId = self.testsRefId() else { return [] }
        
        let summaryRefIds = self.summaryRefIds(from: testsRefId)
        guard !summaryRefIds.isEmpty else { return [] }
        
        return self.testSummaries(from: summaryRefIds)
    }

    private func testsRefId() -> String? {
        let arguments = Constants.xcresulttoolArg + [xcresultBundle]
        
        let executor = Executor(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments))
        let record = executor.exec(for: ActionsInvocationRecord.self)
        
        guard let invocationRecord = record else { return nil }
        
        let testRefId = invocationRecord.actions.first?.actionResult.testsRef.id
        return testRefId
    }

    private func summaryRefIds(from testsRefId: String) -> [String] {
        let arguments = Constants.xcresulttoolArg + [xcresultBundle] + [Constants.xcresultIdArg, testsRefId]
        var summaryRefIds = [String]()
        
        let executor = Executor(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments))
        let runSummaries = executor.exec(for: ActionTestPlanRunSummaries.self)
        
        guard let testPlanRunSummaries = runSummaries else { return summaryRefIds }
        
        let testableSummaries = testPlanRunSummaries.summaries.first?.testableSummaries
        guard let testableSummaryValues = testableSummaries else { return summaryRefIds }

        summaryRefIds = testableSummaryValues.reduce([String]()) { (accumulator, testableSummaryValue) -> [String] in
            let summaryIdentifiableObject =  testableSummaryValue.tests.first?.subtests?.first?.subtests?.first?.subtests
            guard let testSummaryIdentifiableObject = summaryIdentifiableObject else { return accumulator }
            let partialRefIds = testSummaryIdentifiableObject.compactMap({ $0.summaryRef?.id })
            return accumulator + partialRefIds
        }
        return summaryRefIds
    }

    private func testSummaries(from summaryRefIds: [String]) -> [ActionTestSummary] {
        let arguments = Constants.xcresulttoolArg + [xcresultBundle]
        var testSummaries = [ActionTestSummary]()
        for summaryRefId in summaryRefIds {
            let executor = Executor(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments + [Constants.xcresultIdArg, summaryRefId]))
            let summary = executor.exec(for: ActionTestSummary.self)
            guard let testSummary = summary else { continue }
            testSummaries.append(testSummary)
        }
        return testSummaries
    }
}

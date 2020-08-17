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
        let testsRefIds = self.testsRefIds()
        guard !testsRefIds.isEmpty else { return [] }
        
        let summaryRefIds = testsRefIds.reduce([String]()) { (accumulator, testsRefId) -> [String] in
            return accumulator + self.summaryRefIds(from: testsRefId)
        }
        guard !summaryRefIds.isEmpty else { return [] }
        
        return self.testSummaries(from: summaryRefIds)
    }

    private func testsRefIds() -> [String] {
        let arguments = Constants.xcresulttoolArg + [xcresultBundle]
        
        let executor = Executor(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments))
        let record = executor.exec(for: ActionsInvocationRecord.self)
        
        guard let invocationRecord = record else { return [] }
        
        let testRefIds = invocationRecord.actions.map{ $0.actionResult.testsRef.id }
        return testRefIds
    }

    private func summaryRefIds(from testsRefId: String) -> [String] {
        let arguments = Constants.xcresulttoolArg + [xcresultBundle] + [Constants.xcresultIdArg, testsRefId]
        var summaryRefIds = [String]()
        
        let executor = Executor(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments))
        let runSummaries = executor.exec(for: ActionTestPlanRunSummaries.self)
        
        guard let testPlanRunSummaries = runSummaries else { return summaryRefIds }
        
        let testableSummaries = testPlanRunSummaries.summaries.flatMap{ $0.testableSummaries }

        summaryRefIds = testableSummaries.reduce([String]()) { (accumulator, testableSummary) -> [String] in
            let testSummaryIdentifiableObjects = self.testSummaryIdentifiableObjects(for: testableSummary.tests)
            let partialRefIds = testSummaryIdentifiableObjects.compactMap({ $0.summaryRef?.id })
            return accumulator + partialRefIds
        }
        return summaryRefIds
    }

    private func testSummaryIdentifiableObjects(for identifiableObjects: [ActionTestSummaryIdentifiableObject]) -> [ActionTestSummaryIdentifiableObject] {
        var summaryIdentifiableObjects = [ActionTestSummaryIdentifiableObject]()
    
        for summaryIdentifiableObject in identifiableObjects {
            if let IdentifiableObjectSubtests = summaryIdentifiableObject.subtests {
                summaryIdentifiableObjects += self.testSummaryIdentifiableObjects(for: IdentifiableObjectSubtests)
            } else {
                summaryIdentifiableObjects.append(summaryIdentifiableObject)
            }
        }
        return summaryIdentifiableObjects
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

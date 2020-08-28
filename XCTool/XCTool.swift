//
//  TestSummaries.swift
//  XCTool
//
//  Created by Soaurabh Kakkar on 08/08/20.
//

import Foundation

struct XCTool {
    let xcresultBundle: String
    
    func testSummaries() -> [TestSummary] {
        let testsRefIds = self.testsRefIds()
        guard !testsRefIds.isEmpty else { return [] }
        
        let targetSummaryRefs = testsRefIds.reduce([TargetSummaryRef]()) { (accumulator, testsRefId) -> [TargetSummaryRef] in
            return accumulator + self.targetSummaryRefs(from: testsRefId)
        }
        guard !targetSummaryRefs.isEmpty else { return [] }
        
        return self.testSummaries(from: targetSummaryRefs)
    }

    private func testsRefIds() -> [String] {
        let arguments = Constants.xcresulttoolArg + [xcresultBundle]
        
        let executor = Executor(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments))
        let record = executor.exec(for: ActionsInvocationRecord.self)
        
        guard let invocationRecord = record else { return [] }
        
        let testRefIds = invocationRecord.actions.map{ $0.actionResult.testsRef.id }
        return testRefIds
    }

    private func targetSummaryRefs(from testsRefId: String) -> [TargetSummaryRef] {
        let arguments = Constants.xcresulttoolArg + [xcresultBundle] + [Constants.xcresultIdArg, testsRefId]
        var targetSummaryRefs = [TargetSummaryRef]()
        
        let executor = Executor(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments))
        let runSummaries = executor.exec(for: ActionTestPlanRunSummaries.self)
        
        guard let testPlanRunSummaries = runSummaries else { return targetSummaryRefs }
        
        let testableSummaries = testPlanRunSummaries.summaries.flatMap{ $0.testableSummaries }

        targetSummaryRefs = testableSummaries.reduce([TargetSummaryRef]()) { (accumulator, testableSummary) -> [TargetSummaryRef] in
            let targetName = testableSummary.targetName
            let testSummaryIdentifiableObjects = self.testSummaryIdentifiableObjects(for: testableSummary.tests)
            let partialRefIds = testSummaryIdentifiableObjects.compactMap { (summaryIdentifiableObject) -> TargetSummaryRef? in
                guard let summaryRefId = summaryIdentifiableObject.summaryRef?.id else { return nil }
                return TargetSummaryRef(targetName: targetName, id: summaryRefId)
            }
            return accumulator + partialRefIds
        }
        return targetSummaryRefs
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

    private func testSummaries(from targetSummaryRefs: [TargetSummaryRef]) -> [TestSummary] {
        let arguments = Constants.xcresulttoolArg + [xcresultBundle]
        var testSummaries = [TestSummary]()
        for targetSummaryRef in targetSummaryRefs {
            let executor = Executor(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments + [Constants.xcresultIdArg, targetSummaryRef.id]))
            let summary = executor.exec(for: ActionTestSummary.self)
            guard let testSummary = summary else { continue }
            testSummaries.append(TestSummary(actionTestSummary: testSummary, targetName: targetSummaryRef.targetName))
        }
        return testSummaries
    }
}

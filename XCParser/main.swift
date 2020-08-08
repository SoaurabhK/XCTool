//
//  main.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 01/08/20.
//

import Foundation

typealias Executor = REPLExecutor
typealias Command = REPLCommand

func parseTestSummaries(from xcresultFilePath: String) -> [ActionTestSummary] {
    var testSummaries = [ActionTestSummary]()
    
    let arguments = Constants.xcresulttoolArg + [xcresultFilePath]
    
    let root = Executor.exec(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments), for: ActionsInvocationRecord.self)
    
    guard let rootModel = root else { return testSummaries }
    
    let testRefId = rootModel.actions.first?.actionResult.testsRef.id
    guard let testRefIdValue = testRefId else { return testSummaries }
    
    let test = Executor.exec(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments + [Constants.xcresultIdArg, testRefIdValue]), for: ActionTestPlanRunSummaries.self)
    
    guard let testModel = test else { return testSummaries }
    
    let testableSummaries = testModel.summaries.first?.testableSummaries
    guard let testableSummaryValues = testableSummaries else { return testSummaries }

    let summaryRefIdValues = testableSummaryValues.reduce([String?]()) { (accumulator, testableSummaryValue) -> [String?] in
        let summaryIdentifiableObject =  testableSummaryValue.tests.first?.subtests?.first?.subtests?.first?.subtests
        guard let testSummaryIdentifiableObject = summaryIdentifiableObject else { return accumulator }
        let partialRefIds = testSummaryIdentifiableObject.compactMap({ $0.summaryRef?.id })
        return accumulator + partialRefIds
    }

    guard !summaryRefIdValues.isEmpty else { return testSummaries }
    
    for summaryRefId in summaryRefIdValues {
        guard let summaryReferenceId = summaryRefId else { continue }
        let summary = Executor.exec(command: Command(launchPath: Constants.xcrunExecPath, arguments: arguments + [Constants.xcresultIdArg, summaryReferenceId]), for: ActionTestSummary.self)
        guard let testSummary = summary else { continue }
        testSummaries.append(testSummary)
    }
    return testSummaries
}

let resultFilePath = Executor.execTest(Command(launchPath: Constants.xcodebuildExecPath, arguments: Constants.xcodebuildExecArg))

guard let xcresultFilePath = resultFilePath, FileManager.default.fileExists(atPath: xcresultFilePath) else { print("Couldn't find .xcresult file"); exit(-1) }
print("xcresultFilePath: \(xcresultFilePath)")

parseTestSummaries(from: xcresultFilePath).forEach({ dump($0) })



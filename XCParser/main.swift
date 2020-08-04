//
//  main.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 01/08/20.
//

import Foundation

enum Constants {
    static let xcrunExecPath = "/usr/bin/xcrun"
    static let xcodebuildExecPath = "/Applications/Xcode-beta.app/Contents/Developer/usr/bin/xcodebuild"
    static let xcresulttoolArg = ["xcresulttool", "get", "--format", "json", "--path"]
    // user, device and project specific constants
    static let schemeName = "PerformanceTesting"
    static let xcodeprojPath = "/Users/soaurabhkakkar/PerformanceTesting/PerformanceTesting.xcodeproj"
    static let xcodebuildExecArg = ["-project", xcodeprojPath, "-scheme", schemeName, "-destination", "platform=iOS Simulator,name=iPhone 11 Pro Max,OS=14.0", "test"]
}

func model<T: Decodable>(for type: T.Type, launchPath: String, arguments: [String]) -> T? {
    let data = runCommand(launchPath: launchPath, arguments: arguments)
    guard data.exitStatus == 0 else { return nil }
    guard let outData = data.result?.data(using: .utf8) else { return nil }
    let result = try? JSONDecoder().decode(T.self, from: outData)
    return result
}

func execTest(with xcodebuildExecPath: String, arguments: [String]) -> String? {
    let result = execTest(launchPath: xcodebuildExecPath, args: arguments)
    return result.xcresultPath?.trimmingCharacters(in: CharacterSet(charactersIn: "\t"))
}

let resultFilePath = execTest(with: Constants.xcodebuildExecPath, arguments: Constants.xcodebuildExecArg)

guard let xcresultFilePath = resultFilePath, FileManager.default.fileExists(atPath: xcresultFilePath) else { print("Couldn't find .xcresult file"); exit(-1) }

print("===== xcresultFilePath: \(xcresultFilePath) =====")


func parseTestSummaries(from xcresultFilePath: String) -> [TestSummary] {
    var testSummaries = [TestSummary]()
    
    let arguments = Constants.xcresulttoolArg + [xcresultFilePath]
    
    let root = model(for: Root.self, launchPath: Constants.xcrunExecPath, arguments: arguments)
    guard let rootModel = root else { return testSummaries }
    
    let testRefId = rootModel.actions.values.first?.actionResult.testsRef.id.value
    guard let testRefIdValue = testRefId else { return testSummaries }
    
    let test = model(for: Test.self, launchPath: Constants.xcrunExecPath, arguments: arguments + ["--id", testRefIdValue])
    guard let testModel = test else { return testSummaries }
    
    let testableSummaries = testModel.summaries.values.first?.testableSummaries.values
    guard let testableSummaryValues = testableSummaries else { return testSummaries }

    let summaryRefIdValues = testableSummaryValues.reduce([String?]()) { (accumulator, testableSummaryValue) -> [String?] in
        let result =  testableSummaryValue.tests.values.first?.subtests.values.first?.subtests.values.first?.subtests.values.map({$0.summaryRef?.id.value})
        guard let partialRefIds = result else { return accumulator }
        return accumulator + partialRefIds
    }

    guard !summaryRefIdValues.isEmpty else { return testSummaries }
    
    for summaryRefId in summaryRefIdValues {
        guard let summaryReferenceId = summaryRefId else { continue }
        let summary = model(for: TestSummary.self, launchPath: Constants.xcrunExecPath, arguments: arguments + ["--id", summaryReferenceId])
        guard let testSummary = summary else { continue }
        testSummaries.append(testSummary)
    }
    return testSummaries
}

print("========== Test Summaries ==========")
parseTestSummaries(from: xcresultFilePath).forEach({ dump($0) })



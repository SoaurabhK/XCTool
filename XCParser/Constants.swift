//
//  Constants.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 08/08/20.
//

import Foundation

enum Constants {
    static let xcrunExecPath = "/usr/bin/xcrun"
    static let xcodebuildExecPath = "/Applications/Xcode-beta.app/Contents/Developer/usr/bin/xcodebuild"
    static let xcresulttoolArg = ["xcresulttool", "get", "--format", "json", "--path"]
    static let xcresultIdArg = "--id"
    // user, device and project specific constants
    static let schemeName = "PerformanceTesting"
    static let xcodeprojPath = "/Users/soaurabhkakkar/PerformanceTesting/PerformanceTesting.xcodeproj"
    static let xcodebuildExecArg = ["-project", xcodeprojPath, "-scheme", schemeName, "-destination", "platform=iOS Simulator,name=iPhone 11 Pro Max,OS=14.0", "test"]
}

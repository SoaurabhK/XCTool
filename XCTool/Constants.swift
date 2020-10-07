//
//  Constants.swift
//  XCTool
//
//  Created by Soaurabh Kakkar on 08/08/20.
//

import Foundation

enum Constants {
    static let xcrunExecPath = "/usr/bin/xcrun"
    static let xcodebuildExecPath = "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild"
    static let xcresulttoolArg = ["xcresulttool", "get", "--format", "json", "--path"]
    static let xcresultIdArg = "--id"
    static let maxRetries = 3
}

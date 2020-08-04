//
//  RunCommand.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 02/08/20.
//

import Foundation

func runCommand(launchPath: String, arguments: [String]) -> (result: String?, exitStatus: Int32)
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let outdata = pipe.fileHandleForReading.readDataToEndOfFile()
    var output = String(data: outdata, encoding: String.Encoding.utf8)
    output = output?.trimmingCharacters(in: .newlines)
    
    task.waitUntilExit()
    let status = task.terminationStatus

    return (output, status)
}

func execTest(launchPath: String, args: [String]) -> (xcresultPath: String?, exitCode: Int32) {
    var output: String?
    
    let task = Process()
    task.launchPath = launchPath
    task.arguments = args
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let outHandle = pipe.fileHandleForReading
    var buffer = REPLBuffer()
    let group = DispatchGroup()
    
    group.enter()
    outHandle.readabilityHandler = { fileHandle in
        let availableOutData = fileHandle.availableData
        if availableOutData.isEmpty {
            //EOF reached
            output = buffer.outstandingText()?.first(where: { $0.hasSuffix(".xcresult")})
            outHandle.readabilityHandler = nil
            group.leave()
        } else if let line = buffer.append(availableOutData) {
            output = line.hasSuffix(".xcresult") ? line : nil
            print(line)
        }
    }
    
    task.waitUntilExit()
    task.terminationHandler = { process in
        group.wait()
    }
    
    let status = task.terminationStatus
    return (output, status)
}
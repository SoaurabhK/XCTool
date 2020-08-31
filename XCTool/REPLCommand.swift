//
//  RunCommand.swift
//  XCTool
//
//  Created by Soaurabh Kakkar on 02/08/20.
//

import Foundation

struct REPLCommand {
    let launchPath: String
    let arguments: [String]
    
    func run() -> (result: Data?, exitStatus: Int32) {
        let (task, stdOutPipe, _) = launchProcess(at: launchPath, with: arguments)
        let outdata = autoreleasepool { () -> Data? in
            stdOutPipe.fileHandleForReading.readDataToEndOfFile()
        }
        task.waitUntilExit()
        let status = task.terminationStatus

        return (outdata, status)
    }

    @discardableResult
    func run(readabilityHandler: @escaping (([String]?) -> Void)) -> Int32 {
        let (task, stdOutPipe, stdErrPipe) = launchProcess(at: launchPath, with: arguments)
        
        let outHandle = stdOutPipe.fileHandleForReading
        let errHandle = stdErrPipe.fileHandleForReading
        var outBuffer = REPLBuffer()
        var errBuffer = REPLBuffer()
        let group = DispatchGroup()
        
        group.enter()
        outHandle.readabilityHandler = { fileHandle in
            let availableOutData = fileHandle.availableData
            if availableOutData.isEmpty {
                //EOF reached
                readabilityHandler(outBuffer.outstandingText())
                outHandle.readabilityHandler = nil
                group.leave()
            } else if let lines = outBuffer.append(availableOutData) {
                readabilityHandler(lines)
            }
        }
        
        group.enter()
        errHandle.readabilityHandler = { fileHandle in
            let availableOutData = fileHandle.availableData
            if availableOutData.isEmpty {
                //EOF reached
                readabilityHandler(errBuffer.outstandingText())
                errHandle.readabilityHandler = nil
                group.leave()
            } else if let lines = errBuffer.append(availableOutData) {
                readabilityHandler(lines)
            }
        }
        
        task.waitUntilExit()
        
        // readabilityHandler is called on background queue, so it's safe to block/wait here.
        group.wait()
        
        let status = task.terminationStatus
        return status
    }
    
    private func launchProcess(at launchPath: String, with arguments: [String]) -> (task: Process, stdOutPipe: Pipe, stdErrPipe: Pipe) {
        return autoreleasepool { () -> (Process, Pipe, Pipe) in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: launchPath)
            task.arguments = arguments

            let stdOutPipe = Pipe()
            task.standardOutput = stdOutPipe
            
            let stdErrPipe = Pipe()
            task.standardError = stdErrPipe
            
            try? task.run()
            return (task, stdOutPipe, stdErrPipe)
        }
    }
}

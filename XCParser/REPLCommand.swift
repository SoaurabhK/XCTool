//
//  RunCommand.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 02/08/20.
//

import Foundation

struct REPLCommand {
    let launchPath: String
    let arguments: [String]
    
    func run() -> (result: Data?, exitStatus: Int32) {
        let (task, pipe) = launchProcess(at: launchPath, with: arguments)

        let outdata = pipe.fileHandleForReading.readDataToEndOfFile()
        
        task.waitUntilExit()
        let status = task.terminationStatus

        return (outdata, status)
    }

    @discardableResult
    func run(readabilityHandler: @escaping (([String]?) -> Void)) -> Int32 {
        let (task, pipe) = launchProcess(at: launchPath, with: arguments)
        
        let outHandle = pipe.fileHandleForReading
        var buffer = REPLBuffer()
        let group = DispatchGroup()
        
        group.enter()
        outHandle.readabilityHandler = { fileHandle in
            let availableOutData = fileHandle.availableData
            if availableOutData.isEmpty {
                //EOF reached
                readabilityHandler(buffer.outstandingText())
                outHandle.readabilityHandler = nil
                group.leave()
            } else if let line = buffer.append(availableOutData) {
                readabilityHandler([line])
            }
        }
        
        task.waitUntilExit()
        
        // readabilityHandler is called on background queue, so it's safe to block/wait here.
        group.wait()
        
        let status = task.terminationStatus
        return status
    }
    
    private func launchProcess(at launchPath: String, with arguments: [String]) -> (task: Process, pipe: Pipe) {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        return (task, pipe)
    }
}

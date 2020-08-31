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
        let (task, outPipe, _) = launchProcess(at: launchPath, with: arguments)
        let outdata = autoreleasepool { () -> Data? in
            outPipe.fileHandleForReading.readDataToEndOfFile()
        }
        task.waitUntilExit()
        let status = task.terminationStatus

        return (outdata, status)
    }

    @discardableResult
    func run(readabilityHandler: @escaping (([String]?) -> Void)) -> Int32 {
        let (task, outPipe, errPipe) = launchProcess(at: launchPath, with: arguments)
        
        let group = DispatchGroup()
        
        readBuffer(fileHandle: outPipe.fileHandleForReading, dispatchGroup: group, completion: readabilityHandler)
        readBuffer(fileHandle: errPipe.fileHandleForReading, dispatchGroup: group, completion: readabilityHandler)
        
        task.waitUntilExit()
        
        // readabilityHandler is called on background serial queue, so it's safe to block/wait here(i.e. no deadlock)
        group.wait()
        
        return task.terminationStatus
    }
    
    private func readBuffer(fileHandle: FileHandle, dispatchGroup: DispatchGroup, completion: @escaping ([String]?) -> Void) {
        var buffer = REPLBuffer()
        dispatchGroup.enter()
        fileHandle.readabilityHandler = { handle in
            let availableData = handle.availableData
            if availableData.isEmpty {
                //EOF reached
                completion(buffer.outstandingText())
                handle.readabilityHandler = nil
                dispatchGroup.leave()
            } else if let lines = buffer.append(availableData) {
                completion(lines)
            }
        }
    }
    
    private func launchProcess(at launchPath: String, with arguments: [String]) -> (task: Process, outPipe: Pipe, errPipe: Pipe) {
        return autoreleasepool { () -> (Process, Pipe, Pipe) in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: launchPath)
            task.arguments = arguments

            let outPipe = Pipe()
            task.standardOutput = outPipe
            
            let errPipe = Pipe()
            task.standardError = errPipe
            
            try? task.run()
            return (task, outPipe, errPipe)
        }
    }
}

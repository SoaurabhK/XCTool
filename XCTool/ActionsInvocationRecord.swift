//
//  ActionsInvocationRecord.swift
//  XCTool
//
//  Created by Soaurabh Kakkar on 07/08/20.
//

import Foundation

// MARK: - InvocationRecord
struct ActionsInvocationRecord: Codable {
    let actions: [ActionRecord]
    let metadataRef: Reference
    let metrics: ResultMetrics

    enum CodingKeys: String, CodingKey {
        case actions, metadataRef, metrics
    }
    
    enum ActionCodingKeys: String, CodingKey {
        case values = "_values"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let actionsContainer = try rootContainer.nestedContainer(keyedBy: ActionCodingKeys.self, forKey: .actions)
        actions = try actionsContainer.decode([ActionRecord].self, forKey: .values)
        
        metadataRef = try rootContainer.decode(Reference.self, forKey: .metadataRef)
        
        metrics = try rootContainer.decode(ResultMetrics.self, forKey: .metrics)
    }
}

// MARK: - ActionRecord
struct ActionRecord: Codable {
    let actionResult: ActionResult
    let buildResult: BuildResult
    let startedTime, endedTime: String
    let runDestination: ActionRunDestinationRecord
    let schemeCommandName, schemeTaskName: String
    let title: String?
    
    enum CodingKeys: String, CodingKey {
        case actionResult, buildResult, endedTime, runDestination, schemeCommandName, schemeTaskName, startedTime, title
    }
    enum IDCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let startedTimeContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .startedTime)
        startedTime = try startedTimeContainer.decode(String.self, forKey: .value)
        
        let endedTimeContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .endedTime)
        endedTime = try endedTimeContainer.decode(String.self, forKey: .value)
        
        actionResult = try rootContainer.decode(ActionResult.self, forKey: .actionResult)
        buildResult = try rootContainer.decode(BuildResult.self, forKey: .buildResult)
        runDestination = try rootContainer.decode(ActionRunDestinationRecord.self, forKey: .runDestination)
        
        let schemeCmdContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .schemeCommandName)
        schemeCommandName = try schemeCmdContainer.decode(String.self, forKey: .value)
        
        let schemeTaskContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .schemeTaskName)
        schemeTaskName = try schemeTaskContainer.decode(String.self, forKey: .value)
        
        let titleContainer = try? rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .title)
        title = try? titleContainer?.decode(String?.self, forKey: .value)
    }
}

// MARK: - ActionResult
struct ActionResult: Codable {
    let diagnosticsRef: Reference
    let logRef: Reference
    let metrics: ResultMetrics
    let resultName, status: String
    let testsRef: Reference
    
    enum CodingKeys: String, CodingKey {
        case diagnosticsRef, logRef, metrics, resultName, status, testsRef
    }
    
    enum IDCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let resultNameContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .resultName)
        resultName = try resultNameContainer.decode(String.self, forKey: .value)
        
        let statusContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .status)
        status = try statusContainer.decode(String.self, forKey: .value)
        
        diagnosticsRef = try rootContainer.decode(Reference.self, forKey: .diagnosticsRef)
        logRef = try rootContainer.decode(Reference.self, forKey: .logRef)
        metrics = try rootContainer.decode(ResultMetrics.self, forKey: .metrics)
        testsRef = try rootContainer.decode(Reference.self, forKey: .testsRef)
    }
}

// MARK: - ResultMetrics
struct ResultMetrics: Codable {
    let testsCount: Int

    enum CodingKeys: String, CodingKey {
        case testsCount
    }
    enum IDCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let idContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .testsCount)
        testsCount = Int(try idContainer.decode(String.self, forKey: .value)) ?? 0
    }
}

// MARK: - BuildResult
struct BuildResult: Codable {
    let logRef: Reference
    let resultName, status: String

    enum CodingKeys: String, CodingKey {
        case logRef, resultName, status
    }
    enum IDCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let resultContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .resultName)
        resultName = try resultContainer.decode(String.self, forKey: .value)
        
        let statusContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .status)
        status = try statusContainer.decode(String.self, forKey: .value)
        
        logRef = try rootContainer.decode(Reference.self, forKey: .logRef)
    }
}

// MARK: - RunDestinationRecord
struct ActionRunDestinationRecord: Codable {
    let displayName: String
    let localComputerRecord: ActionDeviceRecord
    let targetArchitecture: String
    let targetDeviceRecord: ActionDeviceRecord
    let targetSDKRecord: ActionSDKRecord

    enum CodingKeys: String, CodingKey {
        case displayName, localComputerRecord, targetArchitecture, targetDeviceRecord, targetSDKRecord
    }
    enum IDCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let displayNameContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .displayName)
        displayName = try displayNameContainer.decode(String.self, forKey: .value)
        
        let targetArchContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .targetArchitecture)
        targetArchitecture = try targetArchContainer.decode(String.self, forKey: .value)
        
        localComputerRecord = try rootContainer.decode(ActionDeviceRecord.self, forKey: .localComputerRecord)
        targetDeviceRecord = try rootContainer.decode(ActionDeviceRecord.self, forKey: .targetDeviceRecord)
        targetSDKRecord = try rootContainer.decode(ActionSDKRecord.self, forKey: .targetSDKRecord)
    }
}

// MARK: - DeviceRecord
struct ActionDeviceRecord: Codable {
    let identifier, modelCode, modelName: String
    let isConcreteDevice: Bool
    let modelUTI, name, nativeArchitecture: String
    let operatingSystemVersion, operatingSystemVersionWithBuildNumber: String
    let platformRecord: ActionPlatformRecord
    let busSpeedInMHz, cpuCount, cpuSpeedInMHz, logicalCPUCoresPerPackage, physicalCPUCoresPerPackage: Int?
    let cpuKind: String?
    let ramSizeInMegabytes: Int?

    enum CodingKeys: String, CodingKey {
        case busSpeedInMHz, cpuCount, cpuKind, cpuSpeedInMHz, identifier, isConcreteDevice, logicalCPUCoresPerPackage, modelCode, modelName, modelUTI, name, nativeArchitecture, operatingSystemVersion, operatingSystemVersionWithBuildNumber, physicalCPUCoresPerPackage, platformRecord, ramSizeInMegabytes
    }
    enum IDCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let busSpeedContainer = try? rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .busSpeedInMHz)
        busSpeedInMHz = Int((try? busSpeedContainer?.decode(String?.self, forKey: .value)) ?? String())
        
        let cpuCountContainer = try? rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .cpuCount)
        cpuCount = Int((try? cpuCountContainer?.decode(String?.self, forKey: .value)) ?? String())
        
        let cpuSpeedContainer = try? rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .cpuSpeedInMHz)
        cpuSpeedInMHz = Int((try? cpuSpeedContainer?.decode(String?.self, forKey: .value)) ?? String())
        
        let cpuKindContainer = try? rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .cpuKind)
        cpuKind = try? cpuKindContainer?.decode(String?.self, forKey: .value)
        
        let identifierContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .identifier)
        identifier = try identifierContainer.decode(String.self, forKey: .value)
        
        let modeCodeContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .modelCode)
        modelCode = try modeCodeContainer.decode(String.self, forKey: .value)

        let isConcreteDeviceCont = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .isConcreteDevice)
        isConcreteDevice = Bool(try isConcreteDeviceCont.decode(String.self, forKey: .value)) ?? false
        
        let logicalCPUCoresCont = try? rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .logicalCPUCoresPerPackage)
        logicalCPUCoresPerPackage = Int((try? logicalCPUCoresCont?.decode(String?.self, forKey: .value)) ?? String())
        
        let modelNameContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .modelName)
        modelName = try modelNameContainer.decode(String.self, forKey: .value)
        
        let modeUTIContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .modelUTI)
        modelUTI = try modeUTIContainer.decode(String.self, forKey: .value)
        
        let nameContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .name)
        name = try nameContainer.decode(String.self, forKey: .value)
        
        let nativeArchContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .nativeArchitecture)
        nativeArchitecture = try nativeArchContainer.decode(String.self, forKey: .value)
        
        let osVersionContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .operatingSystemVersion)
        operatingSystemVersion = try osVersionContainer.decode(String.self, forKey: .value)
        
        let osVersionBuildNumCont = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .operatingSystemVersionWithBuildNumber)
        operatingSystemVersionWithBuildNumber = try osVersionBuildNumCont.decode(String.self, forKey: .value)
        
        let physicalCPUCoresCont = try? rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .physicalCPUCoresPerPackage)
        physicalCPUCoresPerPackage = Int((try? physicalCPUCoresCont?.decode(String?.self, forKey: .value)) ?? String())
        
        let ramSizeInMBContainer = try? rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .ramSizeInMegabytes)
        ramSizeInMegabytes = Int((try? ramSizeInMBContainer?.decode(String?.self, forKey: .value)) ?? String())
        
        platformRecord = try rootContainer.decode(ActionPlatformRecord.self, forKey: .platformRecord)
    }
}

// MARK: - PlatformRecord
struct ActionPlatformRecord: Codable {
    let identifier, userDescription: String

    enum CodingKeys: String, CodingKey {
        case identifier, userDescription
    }
    enum IDCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let idContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .identifier)
        identifier = try idContainer.decode(String.self, forKey: .value)
        
        let userDescContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .userDescription)
        userDescription = try userDescContainer.decode(String.self, forKey: .value)
    }
}

// MARK: - TargetSDKRecord
struct ActionSDKRecord: Codable {
    let identifier, name, operatingSystemVersion: String

    enum CodingKeys: String, CodingKey {
        case identifier, name, operatingSystemVersion
    }
    enum IDCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let idContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .identifier)
        identifier = try idContainer.decode(String.self, forKey: .value)
        
        let nameContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .name)
        name = try nameContainer.decode(String.self, forKey: .value)
        
        let osVersionContainer = try rootContainer.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .operatingSystemVersion)
        operatingSystemVersion = try osVersionContainer.decode(String.self, forKey: .value)
    }
}

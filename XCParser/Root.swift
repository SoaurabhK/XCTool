//
//  RootModel.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 01/08/20.
//

import Foundation

// MARK: - Root
struct Root: Codable {
    let type: TypeClass
    let actions: Actions
    let issues: Issues
    let metadataRef: Ref
    let metrics: Metrics

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case actions, issues, metadataRef, metrics
    }
}

// MARK: - Actions
struct Actions: Codable {
    let type: TypeClass
    let values: [Value]

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case values = "_values"
    }
}

// MARK: - TypeClass
struct TypeClass: Codable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name = "_name"
    }
}

// MARK: - Value
struct Value: Codable {
    let type: TypeClass
    let actionResult: ActionResult
    let buildResult: BuildResult
    let endedTime: ID
    let runDestination: RunDestination
    let schemeCommandName, schemeTaskName, startedTime: ID
    let title: ID?
    
    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case actionResult, buildResult, endedTime, runDestination, schemeCommandName, schemeTaskName, startedTime, title
    }
}

// MARK: - ActionResult
struct ActionResult: Codable {
    let type: TypeClass
    let coverage: Issues
    let diagnosticsRef: DiagnosticsRef
    let issues: Issues
    let logRef: Ref
    let metrics: Metrics
    let resultName, status: ID
    let testsRef: Ref

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case coverage, diagnosticsRef, issues, logRef, metrics, resultName, status, testsRef
    }
}

// MARK: - Issues
struct Issues: Codable {
    let type: TypeClass

    enum CodingKeys: String, CodingKey {
        case type = "_type"
    }
}

// MARK: - DiagnosticsRef
struct DiagnosticsRef: Codable {
    let type: TypeClass
    let id: ID

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id
    }
}

// MARK: - ID
struct ID: Codable {
    let type: TypeClass
    let value: String

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case value = "_value"
    }
}

// MARK: - Ref
struct Ref: Codable {
    let type: TypeClass
    let id: ID
    let targetType: RootTargetType

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id, targetType
    }
}

// MARK: - TargetType
struct RootTargetType: Codable {
    let type: TypeClass
    let name: ID

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case name
    }
}

// MARK: - Metrics
struct Metrics: Codable {
    let type: TypeClass
    let testsCount: ID

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case testsCount
    }
}

// MARK: - BuildResult
struct BuildResult: Codable {
    let type: TypeClass
    let coverage, issues: Issues
    let logRef: Ref
    let metrics: Issues
    let resultName, status: ID

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case coverage, issues, logRef, metrics, resultName, status
    }
}

// MARK: - RunDestination
struct RunDestination: Codable {
    let type: TypeClass
    let displayName: ID
    let localComputerRecord: LocalComputerRecord
    let targetArchitecture: ID
    let targetDeviceRecord: TargetDeviceRecord
    let targetSDKRecord: TargetSDKRecord

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case displayName, localComputerRecord, targetArchitecture, targetDeviceRecord, targetSDKRecord
    }
}

// MARK: - LocalComputerRecord
struct LocalComputerRecord: Codable {
    let type: TypeClass
    let busSpeedInMHz, cpuCount, cpuKind, cpuSpeedInMHz: ID
    let identifier, isConcreteDevice, logicalCPUCoresPerPackage, modelCode: ID
    let modelName, modelUTI, name, nativeArchitecture: ID
    let operatingSystemVersion, operatingSystemVersionWithBuildNumber, physicalCPUCoresPerPackage: ID
    let platformRecord: PlatformRecord
    let ramSizeInMegabytes: ID

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case busSpeedInMHz, cpuCount, cpuKind, cpuSpeedInMHz, identifier, isConcreteDevice, logicalCPUCoresPerPackage, modelCode, modelName, modelUTI, name, nativeArchitecture, operatingSystemVersion, operatingSystemVersionWithBuildNumber, physicalCPUCoresPerPackage, platformRecord, ramSizeInMegabytes
    }
}

// MARK: - PlatformRecord
struct PlatformRecord: Codable {
    let type: TypeClass
    let identifier, userDescription: ID

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case identifier, userDescription
    }
}

// MARK: - TargetDeviceRecord
struct TargetDeviceRecord: Codable {
    let type: TypeClass
    let identifier, isConcreteDevice, modelCode, modelName: ID
    let modelUTI, name, nativeArchitecture, operatingSystemVersion: ID
    let operatingSystemVersionWithBuildNumber: ID
    let platformRecord: PlatformRecord

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case identifier, isConcreteDevice, modelCode, modelName, modelUTI, name, nativeArchitecture, operatingSystemVersion, operatingSystemVersionWithBuildNumber, platformRecord
    }
}

// MARK: - TargetSDKRecord
struct TargetSDKRecord: Codable {
    let type: TypeClass
    let identifier, name, operatingSystemVersion: ID

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case identifier, name, operatingSystemVersion
    }
}

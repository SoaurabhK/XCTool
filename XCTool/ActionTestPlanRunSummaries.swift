//
//  ActionTestPlanRunSummaries.swift
//  XCTool
//
//  Created by Soaurabh Kakkar on 07/08/20.
//

import Foundation

// MARK: - TestPlanRunSummaries
struct ActionTestPlanRunSummaries: Codable {
    let summaries: [ActionTestPlanRunSummary]

    enum CodingKeys: String, CodingKey {
        case summaries
    }
    
    enum SummariesCodingKeys: String, CodingKey {
        case values = "_values"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let summariesContainer = try rootContainer.nestedContainer(keyedBy: SummariesCodingKeys.self, forKey: .summaries)
        summaries = try summariesContainer.decode([ActionTestPlanRunSummary].self, forKey: .values)
    }
}

// MARK: - TestPlanRunSummary
struct ActionTestPlanRunSummary: Codable {
    let name: String
    let testableSummaries: [ActionTestableSummary]

    enum CodingKeys: String, CodingKey {
        case name, testableSummaries
    }
    
    enum TestableSummariesCodingKeys: String, CodingKey {
        case values = "_values"
    }
    
    enum NameCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let summariesContainer = try rootContainer.nestedContainer(keyedBy: TestableSummariesCodingKeys.self, forKey: .testableSummaries)
        testableSummaries = try summariesContainer.decode([ActionTestableSummary].self, forKey: .values)
        
        let nameContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        name = try nameContainer.decode(String.self, forKey: .value)
    }
}

// MARK:- TargetSummaryRef
struct TargetSummaryRef {
    let targetName: String
    let id: String //summaryRefId
}

// MARK: - TestableSummary
struct ActionTestableSummary: Codable {
    let diagnosticsDirectoryName, name, projectRelativePath, targetName: String
    let testKind: String
    let tests: [ActionTestSummaryIdentifiableObject]

    enum CodingKeys: String, CodingKey {
        case diagnosticsDirectoryName, name, projectRelativePath, targetName, testKind, tests
    }
    
    enum NameCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    enum TestsCodingKeys: String, CodingKey {
        case values = "_values"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let nameContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        name = try nameContainer.decode(String.self, forKey: .value)
        
        let diagDirNameContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .diagnosticsDirectoryName)
        diagnosticsDirectoryName = try diagDirNameContainer.decode(String.self, forKey: .value)
        
        let projRelPathContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .projectRelativePath)
        projectRelativePath = try projRelPathContainer.decode(String.self, forKey: .value)
        
        let targetNameContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .targetName)
        targetName = try targetNameContainer.decode(String.self, forKey: .value)
        
        let testKindContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .testKind)
        testKind = try testKindContainer.decode(String.self, forKey: .value)
        
        let testsContainer = try rootContainer.nestedContainer(keyedBy: TestsCodingKeys.self, forKey: .tests)
        tests = try testsContainer.decode([ActionTestSummaryIdentifiableObject].self, forKey: .values)
    }
    
}

// MARK: - TestSummaryIdentifiableObject
class ActionTestSummaryIdentifiableObject: Codable {
    let duration: Double?
    let identifier, name: String
    let subtests: [ActionTestSummaryIdentifiableObject]?
    let summaryRef: Reference?
    let testStatus: String?

    enum NameCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    enum CodingKeys: String, CodingKey {
        case duration, identifier, name, subtests, summaryRef, testStatus
    }
    
    enum SubTestsCodingKeys: String, CodingKey {
        case values = "_values"
    }
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let nameContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        name = try nameContainer.decode(String.self, forKey: .value)
        
        let identifierContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .identifier)
        identifier = try identifierContainer.decode(String.self, forKey: .value)
        
        let durationContainer = try? rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .duration)
        duration = try? durationContainer?.decode(String?.self, forKey: .value).flatMap(Double.init)
        
        let testStatusContainer = try? rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .testStatus)
        testStatus = try? testStatusContainer?.decode(String?.self, forKey: .value)
        
        let subtestsContainer = try? rootContainer.nestedContainer(keyedBy: SubTestsCodingKeys.self, forKey: .subtests)
        subtests = try? subtestsContainer?.decode([ActionTestSummaryIdentifiableObject]?.self, forKey: .values)
        summaryRef = try? rootContainer.decode(Reference?.self, forKey: .summaryRef)
    }
}

// MARK: - SummaryRef
struct Reference: Codable {
    let id: String
    let targetType: TypeDefinition?
    
    enum NameCodingKeys: String, CodingKey {
        case value = "_value"
    }

    enum CodingKeys: String, CodingKey {
        case id, targetType
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let nameContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .id)
        id = try nameContainer.decode(String.self, forKey: .value)
        targetType = try? rootContainer.decode(TypeDefinition?.self, forKey: .targetType)
    }
}

// MARK: - TypeDefinition
class TypeDefinition: Codable {
    let name: String
    let supertype: TypeDefinition?
    
    enum NameCodingKeys: String, CodingKey {
        case value = "_value"
    }

    enum CodingKeys: String, CodingKey {
        case name, supertype
    }
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let nameContainer = try rootContainer.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        name = try nameContainer.decode(String.self, forKey: .value)
        supertype = try? rootContainer.decode(TypeDefinition?.self, forKey: .supertype)
    }
}

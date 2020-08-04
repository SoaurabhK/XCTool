//
//  Test.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 01/08/20.
//

import Foundation

// MARK: - Test
struct Test: Codable {
    let type: TestType // "ActionAbstractTestSummary"
    let summaries: Summaries

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case summaries
    }
}

// MARK: - Summaries
struct Summaries: Codable {
    let type: TestType // "Array"
    let values: [SummariesValue] // .first

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case values = "_values"
    }
}

// MARK: - TestType
struct TestType: Codable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name = "_name"
    }
}

// MARK: - SummariesValue
struct SummariesValue: Codable {
    let type: ValueSupertype
    let name: Name
    let testableSummaries: TestableSummaries

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case name, testableSummaries
    }
}

// MARK: - Name
struct Name: Codable {
    let type: TestType
    let value: String

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case value = "_value"
    }
}

// MARK: - TestableSummaries
struct TestableSummaries: Codable {
    let type: TestType // array
    let values: [TestableSummariesValue] // .first

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case values = "_values"
    }
}

// MARK: - TestableSummariesValue
struct TestableSummariesValue: Codable {
    let type: ValueSupertype
    let diagnosticsDirectoryName, name, projectRelativePath, targetName: Name
    let testKind: Name
    let tests: Tests

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case diagnosticsDirectoryName, name, projectRelativePath, targetName, testKind, tests
    }
}

// MARK: - Tests
struct Tests: Codable {
    let type: TestType // array
    let values: [TestsValue] // .first

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case values = "_values"
    }
}

// MARK: - TestsValue
struct TestsValue: Codable {
    let type: PurpleType
    let duration, identifier, name: Name
    let subtests: PurpleSubtests

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case duration, identifier, name, subtests
    }
}

// MARK: - PurpleSubtests
struct PurpleSubtests: Codable {
    let type: TestType // array
    let values: [PurpleValue] // .first

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case values = "_values"
    }
}

// MARK: - PurpleValue
struct PurpleValue: Codable {
    let type: PurpleType
    let duration, identifier, name: Name
    let subtests: FluffySubtests

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case duration, identifier, name, subtests
    }
}

// MARK: - FluffySubtests
struct FluffySubtests: Codable {
    let type: TestType //array
    let values: [FluffyValue] // .first

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case values = "_values"
    }
}

// MARK: - FluffyValue
struct FluffyValue: Codable {
    let type: PurpleType
    let duration, identifier, name: Name
    let subtests: TentacledSubtests

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case duration, identifier, name, subtests
    }
}

// MARK: - TentacledSubtests
struct TentacledSubtests: Codable {
    let type: TestType
    let values: [TentacledValue] //for each here.

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case values = "_values"
    }
}

// MARK: - TentacledValue, test metadata
struct TentacledValue: Codable {
    let type: PurpleType
    let duration, identifier, name: Name
    let summaryRef: SummaryRef?
    let testStatus: Name

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case duration, identifier, name, summaryRef, testStatus
    }
}

// MARK: - SummaryRef
struct SummaryRef: Codable {
    let type: TestType
    let id: Name
    let targetType: TargetType

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case id, targetType
    }
}

// MARK: - TargetType
struct TargetType: Codable {
    let type: TestType
    let name: Name
    let supertype: TargetTypeSupertype

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case name, supertype
    }
}

// MARK: - TargetTypeSupertype
struct TargetTypeSupertype: Codable {
    let type: TestType
    let name: Name
    let supertype: SupertypeSupertype

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case name, supertype
    }
}

// MARK: - SupertypeSupertype
struct SupertypeSupertype: Codable {
    let type: TestType
    let name: Name

    enum CodingKeys: String, CodingKey {
        case type = "_type"
        case name
    }
}

// MARK: - PurpleType
struct PurpleType: Codable {
    let name: String
    let supertype: ValueSupertype

    enum CodingKeys: String, CodingKey {
        case name = "_name"
        case supertype = "_supertype"
    }
}

// MARK: - ValueSupertype
struct ValueSupertype: Codable {
    let name: String
    let supertype: TestType

    enum CodingKeys: String, CodingKey {
        case name = "_name"
        case supertype = "_supertype"
    }
}

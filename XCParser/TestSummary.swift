//
//  Summary.swift
//  XCParser
//
//  Created by Soaurabh Kakkar on 02/08/20.
//

import Foundation

// MARK: - TestSummary
struct TestSummary: Codable {
    let performanceMetrics: [PerformanceMetricsValue]
    let duration: Double
    let identifier, name: String
    let testStatus: String
    
    enum CodingKeys: String, CodingKey {
        case duration, identifier, name, performanceMetrics, testStatus
    }
    
    enum DurationCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    enum PerfMetricsCodingKeys: String, CodingKey {
        case values = "_values"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let perfMetricsContainer = try rootContainer.nestedContainer(keyedBy: PerfMetricsCodingKeys.self, forKey: .performanceMetrics)
        performanceMetrics = try perfMetricsContainer.decode([PerformanceMetricsValue].self, forKey: .values)
        
        let testStatusContainer = try rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .testStatus)
        testStatus = try testStatusContainer.decode(String.self, forKey: .value)
        
        let identifierContainer = try rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .identifier)
        identifier = try identifierContainer.decode(String.self, forKey: .value)
        
        let nameContainer = try rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .name)
        name = try nameContainer.decode(String.self, forKey: .value)
        
        let durationContainer = try rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .duration)
        duration = Double(try durationContainer.decode(String.self, forKey: .value)) ?? 0.0
    }
}

// MARK: - PerformanceMetricsValue
struct PerformanceMetricsValue: Codable {
    let displayName, identifier: String
    let maxPercentRegression, maxPercentRelativeStandardDeviation: Double
    let maxRegression, maxStandardDeviation: Double?
    let measurements: [Double]
    let unitOfMeasurement: String

    enum CodingKeys: String, CodingKey {
        case displayName, identifier, maxPercentRegression, maxPercentRelativeStandardDeviation, measurements, unitOfMeasurement, maxRegression, maxStandardDeviation
    }
    enum DurationCodingKeys: String, CodingKey {
        case value = "_value"
    }
    
    enum MeasurementsCodingKeys: String, CodingKey {
        case values = "_values"
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        let displayNameContainer = try rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .displayName)
        displayName = try displayNameContainer.decode(String.self, forKey: .value)
        
        let identifierContainer = try rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .identifier)
        identifier = try identifierContainer.decode(String.self, forKey: .value)
        
        let percentRegContainer = try rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .maxPercentRegression)
        maxPercentRegression = Double(try percentRegContainer.decode(String.self, forKey: .value)) ?? 0.0
        
        let percentRelSDContainer = try rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .maxPercentRelativeStandardDeviation)
        maxPercentRelativeStandardDeviation = Double(try percentRelSDContainer.decode(String.self, forKey: .value)) ?? 0.0
        
        let maxRegContainer = try? rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .maxRegression)
        maxRegression = Double((try? maxRegContainer?.decode(String?.self, forKey: .value)) ?? String())
        
        let maxSDContainer = try? rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .maxStandardDeviation)
        maxStandardDeviation = Double((try? maxSDContainer?.decode(String?.self, forKey: .value)) ?? String())
        
        let unitContainer = try rootContainer.nestedContainer(keyedBy: DurationCodingKeys.self, forKey: .unitOfMeasurement)
        unitOfMeasurement = try unitContainer.decode(String.self, forKey: .value)
        
        let measurementContainer = try rootContainer.nestedContainer(keyedBy: MeasurementsCodingKeys.self, forKey: .measurements)
        var measurementValContainer = try measurementContainer.nestedUnkeyedContainer(forKey: .values)
        var measurements = [Double]()
        while !measurementValContainer.isAtEnd {
            let leafContainer = try measurementValContainer.nestedContainer(keyedBy: DurationCodingKeys.self)
            let value = Double(try leafContainer.decode(String.self, forKey: .value))
            guard let finalValue = value else { continue }
            measurements.append(finalValue)
        }
        self.measurements = measurements
    }
}

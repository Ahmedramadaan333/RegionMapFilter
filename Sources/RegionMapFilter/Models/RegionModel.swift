//
//  RegionModel.swift
//  RegionMapFilter
//
//  Created by Ahmed Ramadan
//  Copyright © 2024 RegionMapFilter. All rights reserved.
//

import Foundation
import GoogleMaps

// MARK: - Region Model
public struct Region {
    public let name: String
    public let arabicName: String
    public let coordinates: [[[Double]]]
    public var polygon: GMSPolygon?
    public var isSelected: Bool = false
    
    public init(name: String, arabicName: String = "", coordinates: [[[Double]]]) {
        self.name = name
        self.arabicName = arabicName
        self.coordinates = coordinates
    }
}

// MARK: - GeoJSON Response Models
struct GeoJSONResponse: Codable {
    let type: String
    let features: [RegionFeature]
}

struct RegionFeature: Codable {
    let type: String
    let properties: RegionProperties
    let geometry: RegionGeometry
}

struct RegionProperties: Codable {
    let shapeName: String
    let arabicName: String?
    
    enum CodingKeys: String, CodingKey {
        case shapeName
        case arabicName
    }
}

struct RegionGeometry: Codable {
    let type: String
    let coordinates: [[[Double]]]
    
    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        
        // Handle both Polygon and MultiPolygon
        if type == "MultiPolygon" {
            let multiPolygon = try container.decode([[[[Double]]]].self, forKey: .coordinates)
            coordinates = multiPolygon.first ?? []
        } else {
            coordinates = try container.decode([[[Double]]].self, forKey: .coordinates)
        }
    }
}

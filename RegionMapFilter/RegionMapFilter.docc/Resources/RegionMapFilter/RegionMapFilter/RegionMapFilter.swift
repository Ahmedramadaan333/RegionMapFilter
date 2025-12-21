//
//  RegionMapFilter.swift
//  RegionMapFilter
//
//  Created by Ahmed Ramadan
//  Copyright © 2024 RegionMapFilter. All rights reserved.
//

import Foundation
import GoogleMaps

public final class RegionMapFilter {
    
    // MARK: - Singleton (optional)
    public static let shared = RegionMapFilter()
    
    // MARK: - Google Maps API Key
    private var apiKey: String?
    
    private init() {}
    
    // MARK: - Configuration
    public func configure(googleMapsAPIKey: String) {
        self.apiKey = googleMapsAPIKey
        GMSServices.provideAPIKey(googleMapsAPIKey)
    }
    
    // MARK: - Create ViewController
    public func createViewController(
        configuration: RegionMapConfiguration
    ) -> RegionMapViewController {
        guard apiKey != nil else {
            fatalError("RegionMapFilter: Google Maps API key not configured. Call configure(googleMapsAPIKey:) first.")
        }
        
        return RegionMapViewController(configuration: configuration)
    }
}

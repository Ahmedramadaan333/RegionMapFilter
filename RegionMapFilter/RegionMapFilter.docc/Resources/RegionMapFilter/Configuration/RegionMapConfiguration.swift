//
//  RegionMapConfiguration.swift
//  RegionMapFilter
//
//  Created by Ahmed Ramadan
//  Copyright © 2024 RegionMapFilter. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit

/// Configuration for RegionMapViewController
/// Contains all customization options for the map filter
public struct RegionMapConfiguration {
    
    // MARK: - Required Configuration
    
    /// Name of the GeoJSON file (without extension)
    public let geoJSONFileName: String
    
    /// File extension of the GeoJSON file (default: "geojson")
    public let geoJSONFileExtension: String
    
    /// Bundle containing the GeoJSON file (default: .main)
    public let bundle: Bundle
    
    // MARK: - Map Configuration
    
    /// Initial camera position when map loads
    public let initialCameraPosition: GMSCameraPosition
    
    /// Default zoom level for the map
    public let defaultZoomLevel: Float
    
    // MARK: - Styling Configuration
    
    /// Fill color for selected region polygon
    public let selectedRegionFillColor: UIColor
    
    /// Stroke color for selected region polygon
    public let selectedRegionStrokeColor: UIColor
    
    /// Stroke width for selected region polygon
    public let selectedRegionStrokeWidth: CGFloat
    
    /// Fill color for unselected region polygons
    public let unselectedRegionFillColor: UIColor
    
    /// Stroke color for unselected region polygons
    public let unselectedRegionStrokeColor: UIColor
    
    /// Stroke width for unselected region polygons
    public let unselectedRegionStrokeWidth: CGFloat
    
    /// Color for location marker pin
    public let markerColor: UIColor
    
    // MARK: - Localization Strings
    
    /// Text for filter button (default: "Filter Region")
    public let filterButtonTitle: String
    
    /// Title for region selection popup (default: "Select Region")
    public let selectRegionTitle: String
    
    /// Placeholder text for search bar (default: "Search region...")
    public let searchPlaceholder: String
    
    /// Empty state message when no regions found (default: "No regions found")
    public let noRegionsFoundMessage: String
    
    /// Alert title when user must select region first (default: "Select Region First")
    public let selectRegionFirstTitle: String
    
    /// Alert message when user must select region first
    public let selectRegionFirstMessage: String
    
    /// Alert title when location is not allowed (default: "Location Not Allowed")
    public let locationNotAllowedTitle: String
    
    /// Alert message when location is not allowed
    public let locationNotAllowedMessage: String
    
    /// Confirm button text (default: "Confirm Location")
    public let confirmButtonTitle: String
    
    // MARK: - Initializer
    
    /// Initialize RegionMapConfiguration
    /// - Parameters:
    ///   - geoJSONFileName: Name of the GeoJSON file (without extension)
    ///   - geoJSONFileExtension: File extension (default: "geojson")
    ///   - bundle: Bundle containing the file (default: .main)
    ///   - initialLatitude: Initial camera latitude
    ///   - initialLongitude: Initial camera longitude
    ///   - defaultZoomLevel: Default zoom level (default: 5)
    ///   - selectedRegionFillColor: Fill color for selected region (default: .white)
    ///   - selectedRegionStrokeColor: Border color for selected region (default: .systemGreen)
    ///   - selectedRegionStrokeWidth: Border width for selected region (default: 3)
    ///   - unselectedRegionFillColor: Fill color for unselected regions (default: light gray with alpha)
    ///   - unselectedRegionStrokeColor: Border color for unselected regions (default: gray with alpha)
    ///   - unselectedRegionStrokeWidth: Border width for unselected regions (default: 1)
    ///   - markerColor: Color for location marker (default: .systemRed)
    ///   - filterButtonTitle: Text for filter button (default: "Filter Region")
    ///   - selectRegionTitle: Title for selection popup (default: "Select Region")
    ///   - searchPlaceholder: Search bar placeholder (default: "Search region...")
    ///   - noRegionsFoundMessage: Empty state message (default: "No regions found")
    ///   - selectRegionFirstTitle: Alert title for region requirement (default: "Select Region First")
    ///   - selectRegionFirstMessage: Alert message for region requirement
    ///   - locationNotAllowedTitle: Alert title for invalid location (default: "Location Not Allowed")
    ///   - locationNotAllowedMessage: Alert message for invalid location
    ///   - confirmButtonTitle: Confirm button text (default: "Confirm Location")
    public init(
        geoJSONFileName: String,
        geoJSONFileExtension: String = "geojson",
        bundle: Bundle = .main,
        initialLatitude: Double = 24.7136,
        initialLongitude: Double = 46.6753,
        defaultZoomLevel: Float = 5,
        selectedRegionFillColor: UIColor = .white,
        selectedRegionStrokeColor: UIColor = .systemGreen,
        selectedRegionStrokeWidth: CGFloat = 3,
        unselectedRegionFillColor: UIColor = UIColor.lightGray.withAlphaComponent(0.3),
        unselectedRegionStrokeColor: UIColor = UIColor.gray.withAlphaComponent(0.5),
        unselectedRegionStrokeWidth: CGFloat = 1,
        markerColor: UIColor = .systemRed,
        filterButtonTitle: String = "Filter Region",
        selectRegionTitle: String = "Select Region",
        searchPlaceholder: String = "Search region...",
        noRegionsFoundMessage: String = "No regions found",
        selectRegionFirstTitle: String = "Select Region First",
        selectRegionFirstMessage: String = "Please select a region from the filter before choosing a location",
        locationNotAllowedTitle: String = "Location Not Allowed",
        locationNotAllowedMessage: String = "Please select a location within the filtered region",
        confirmButtonTitle: String = "Confirm Location"
    ) {
        self.geoJSONFileName = geoJSONFileName
        self.geoJSONFileExtension = geoJSONFileExtension
        self.bundle = bundle
        self.initialCameraPosition = GMSCameraPosition(
            latitude: initialLatitude,
            longitude: initialLongitude,
            zoom: defaultZoomLevel
        )
        self.defaultZoomLevel = defaultZoomLevel
        
        // Styling
        self.selectedRegionFillColor = selectedRegionFillColor
        self.selectedRegionStrokeColor = selectedRegionStrokeColor
        self.selectedRegionStrokeWidth = selectedRegionStrokeWidth
        self.unselectedRegionFillColor = unselectedRegionFillColor
        self.unselectedRegionStrokeColor = unselectedRegionStrokeColor
        self.unselectedRegionStrokeWidth = unselectedRegionStrokeWidth
        self.markerColor = markerColor
        
        // Localization
        self.filterButtonTitle = filterButtonTitle
        self.selectRegionTitle = selectRegionTitle
        self.searchPlaceholder = searchPlaceholder
        self.noRegionsFoundMessage = noRegionsFoundMessage
        self.selectRegionFirstTitle = selectRegionFirstTitle
        self.selectRegionFirstMessage = selectRegionFirstMessage
        self.locationNotAllowedTitle = locationNotAllowedTitle
        self.locationNotAllowedMessage = locationNotAllowedMessage
        self.confirmButtonTitle = confirmButtonTitle
    }
}

// MARK: - Convenience Initializers
extension RegionMapConfiguration {
    
    /// Create configuration for Saudi Arabia regions
    /// - Parameters:
    ///   - geoJSONFileName: GeoJSON file name (default: "SAU_ADM2_ENHANCED")
    ///   - bundle: Bundle containing file (default: .main)
    /// - Returns: Configured instance for Saudi Arabia
    public static func saudiArabia(
        geoJSONFileName: String = "SAU_ADM2_ENHANCED",
        bundle: Bundle = .main
    ) -> RegionMapConfiguration {
        return RegionMapConfiguration(
            geoJSONFileName: geoJSONFileName,
            bundle: bundle,
            initialLatitude: 24.7136,
            initialLongitude: 46.6753,
            defaultZoomLevel: 5,
            filterButtonTitle: "Filter Region",
            selectRegionTitle: "Select Region"
        )
    }
    
    /// Create configuration with custom location
    /// - Parameters:
    ///   - geoJSONFileName: GeoJSON file name
    ///   - latitude: Initial latitude
    ///   - longitude: Initial longitude
    ///   - zoom: Initial zoom level
    ///   - bundle: Bundle containing file (default: .main)
    /// - Returns: Configured instance
    public static func custom(
        geoJSONFileName: String,
        latitude: Double,
        longitude: Double,
        zoom: Float = 5,
        bundle: Bundle = .main
    ) -> RegionMapConfiguration {
        return RegionMapConfiguration(
            geoJSONFileName: geoJSONFileName,
            bundle: bundle,
            initialLatitude: latitude,
            initialLongitude: longitude,
            defaultZoomLevel: zoom
        )
    }
}

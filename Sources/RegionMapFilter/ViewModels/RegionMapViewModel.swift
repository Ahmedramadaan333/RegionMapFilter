//
//  RegionMapViewModel.swift
//  RegionMapFilter
//
//  Created by Ahmed Ramadan
//  Copyright © 2024 RegionMapFilter. All rights reserved.
//

import Foundation
import Combine
import GoogleMaps
import CoreLocation

public class RegionMapViewModel {
    
    // MARK: - Published Properties
    @Published public var regions: [Region] = []
    @Published public var filteredRegions: [Region] = []
    @Published public var selectedRegion: Region?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var searchText: String = "" {
        didSet {
            filterRegions()
        }
    }
    
    // MARK: - Configuration
    private let configuration: RegionMapConfiguration
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    public init(configuration: RegionMapConfiguration) {
        self.configuration = configuration
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterRegions()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    public func loadGeoJSON() {
        isLoading = true
        errorMessage = nil
        
        guard let url = configuration.bundle.url(
            forResource: configuration.geoJSONFileName,
            withExtension: configuration.geoJSONFileExtension
        ) else {
            errorMessage = "GeoJSON file not found"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let geoJSON = try decoder.decode(GeoJSONResponse.self, from: data)
            
            var loadedRegions: [Region] = []
            
            for feature in geoJSON.features {
                let englishName = feature.properties.shapeName
                let arabicName = feature.properties.arabicName ?? ""
                
                var region = Region(
                    name: englishName,
                    arabicName: arabicName,
                    coordinates: feature.geometry.coordinates
                )
                
                loadedRegions.append(region)
            }
            
            self.regions = loadedRegions.sorted { $0.name < $1.name }
            self.filteredRegions = self.regions
            self.isLoading = false
            
        } catch {
            errorMessage = "Failed to load GeoJSON: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    public func selectRegion(_ region: Region) {
        // Deselect previous region
        if let previousIndex = regions.firstIndex(where: { $0.name == selectedRegion?.name }) {
            regions[previousIndex].isSelected = false
        }
        
        // Select new region
        if let index = regions.firstIndex(where: { $0.name == region.name }) {
            regions[index].isSelected = true
            selectedRegion = regions[index]
        }
        
        filterRegions()
    }
    
    public func clearSelection() {
        if let index = regions.firstIndex(where: { $0.name == selectedRegion?.name }) {
            regions[index].isSelected = false
        }
        selectedRegion = nil
        filterRegions()
    }
    
    public func isLocationInSelectedRegion(_ coordinate: CLLocationCoordinate2D) -> Bool {
        guard let selectedRegion = selectedRegion else { return false }
        return isCoordinate(coordinate, insideRegion: selectedRegion)
    }
    
    // MARK: - Private Methods
    private func filterRegions() {
        if searchText.isEmpty {
            filteredRegions = regions
        } else {
            filteredRegions = regions.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.arabicName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func isCoordinate(_ coordinate: CLLocationCoordinate2D, insideRegion region: Region) -> Bool {
        let point = CGPoint(x: coordinate.longitude, y: coordinate.latitude)
        
        for polygonCoords in region.coordinates {
            var polygonPoints: [CGPoint] = []
            for coord in polygonCoords {
                let longitude = coord[0]
                let latitude = coord[1]
                polygonPoints.append(CGPoint(x: longitude, y: latitude))
            }
            
            if isPoint(point, insidePolygon: polygonPoints) {
                return true
            }
        }
        
        return false
    }
    
    private func isPoint(_ point: CGPoint, insidePolygon polygon: [CGPoint]) -> Bool {
        var isInside = false
        var j = polygon.count - 1
        
        for i in 0..<polygon.count {
            let xi = polygon[i].x
            let yi = polygon[i].y
            let xj = polygon[j].x
            let yj = polygon[j].y
            
            if ((yi > point.y) != (yj > point.y)) &&
                (point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi) {
                isInside = !isInside
            }
            
            j = i
        }
        
        return isInside
    }
    
    public func createPolygon(for region: Region) -> GMSPolygon {
        let path = GMSMutablePath()
        
        for polygonCoords in region.coordinates {
            for coord in polygonCoords {
                let longitude = coord[0]
                let latitude = coord[1]
                path.add(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
        
        let polygon = GMSPolygon(path: path)
        
        if region.isSelected {
            polygon.fillColor = configuration.selectedRegionFillColor
            polygon.strokeColor = configuration.selectedRegionStrokeColor
            polygon.strokeWidth = configuration.selectedRegionStrokeWidth
        } else {
            polygon.fillColor = configuration.unselectedRegionFillColor
            polygon.strokeColor = configuration.unselectedRegionStrokeColor
            polygon.strokeWidth = configuration.unselectedRegionStrokeWidth
        }
        
        return polygon
    }
    
    public func getCameraBounds(for region: Region) -> GMSCoordinateBounds? {
        var bounds = GMSCoordinateBounds()
        
        for polygonCoords in region.coordinates {
            for coord in polygonCoords {
                let longitude = coord[0]
                let latitude = coord[1]
                bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        }
        
        return bounds
    }
}

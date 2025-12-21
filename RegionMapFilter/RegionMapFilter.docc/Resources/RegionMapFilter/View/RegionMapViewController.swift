//
//  RegionMapViewController.swift
//  RegionMapFilter
//
//  Created by Ahmed Ramadan
//  Copyright © 2024 RegionMapFilter. All rights reserved.
//

import UIKit
import GoogleMaps
import Combine
import CoreLocation

public protocol RegionMapDelegate: AnyObject {
    func regionMapDidSelectLocation(_ coordinate: CLLocationCoordinate2D, address: String)
    func regionMapDidSelectRegion(_ region: Region)
    func regionMapDidClearSelection()
}

public class RegionMapViewController: UIViewController {
    
    // MARK: - Public Properties
    public weak var delegate: RegionMapDelegate?
    
    // MARK: - Completion Handlers
    public var onLocationSelected: ((CLLocationCoordinate2D, String) -> Void)?
    public var onRegionSelected: ((Region) -> Void)?
    public var onSelectionCleared: (() -> Void)?
    
    // MARK: - UI Components
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let clearFilterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 8
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let selectedLocationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm Location", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Configuration & Properties
    private let configuration: RegionMapConfiguration
    private let viewModel: RegionMapViewModel
    
    public var mapView: GMSMapView!
    private var regionPolygons: [String: GMSPolygon] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var selectedMarker: GMSMarker?
    private let geocoder = CLGeocoder()
    private var currentCoordinate: CLLocationCoordinate2D?
    
    // MARK: - Initializer
    public init(configuration: RegionMapConfiguration) {
        self.configuration = configuration
        self.viewModel = RegionMapViewModel(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(configuration:)")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMap()
        setupFilterButton()
        setupSelectedLocationView()
        setupBindings()
        setupActions()
        viewModel.loadGeoJSON()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
    }
    
    private func setupMap() {
        setupMapView()
        setupMapConstraints()
    }
    
    private func setupMapView() {
        mapView = GMSMapView()
        mapView.camera = configuration.initialCameraPosition
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.insertSubview(mapView, at: 0)
    }
    
    private func setupMapConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        view.addSubview(clearFilterButton)
        
        updateFilterButtonConfiguration(text: configuration.filterButtonTitle)
        
        NSLayoutConstraint.activate([
            filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
            
            clearFilterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            clearFilterButton.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -12),
            clearFilterButton.widthAnchor.constraint(equalToConstant: 40),
            clearFilterButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupSelectedLocationView() {
        view.addSubview(selectedLocationView)
        selectedLocationView.addSubview(addressLabel)
        selectedLocationView.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            selectedLocationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedLocationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectedLocationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            selectedLocationView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            addressLabel.topAnchor.constraint(equalTo: selectedLocationView.topAnchor, constant: 16),
            addressLabel.leadingAnchor.constraint(equalTo: selectedLocationView.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: selectedLocationView.trailingAnchor, constant: -16),
            
            confirmButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 12),
            confirmButton.leadingAnchor.constraint(equalTo: selectedLocationView.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: selectedLocationView.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: selectedLocationView.bottomAnchor, constant: -16),
            confirmButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupBindings() {
        viewModel.$regions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMapPolygons()
            }
            .store(in: &cancellables)
        
        viewModel.$selectedRegion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] region in
                self?.handleRegionSelection(region)
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        clearFilterButton.addTarget(self, action: #selector(clearFilterTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func filterButtonTapped() {
        let popupVC = RegionSelectionPopupViewController(viewModel: viewModel, configuration: configuration)
        popupVC.delegate = self
        present(popupVC, animated: false)
    }
    
    @objc private func clearFilterTapped() {
        viewModel.clearSelection()
        onSelectionCleared?()
        delegate?.regionMapDidClearSelection()
    }
    
    @objc private func confirmButtonTapped() {
        guard let coordinate = currentCoordinate else { return }
        let address = addressLabel.text ?? ""
        
        onLocationSelected?(coordinate, address)
        delegate?.regionMapDidSelectLocation(coordinate, address: address)
    }
    
    // MARK: - Map Management
    private func updateMapPolygons() {
        // Clear existing polygons
        regionPolygons.values.forEach { $0.map = nil }
        regionPolygons.removeAll()
        
        // Create new polygons
        for region in viewModel.regions {
            let polygon = viewModel.createPolygon(for: region)
            polygon.map = mapView
            regionPolygons[region.name] = polygon
        }
    }
    
    private func handleRegionSelection(_ region: Region?) {
        if let region = region {
            // Hide selected location view and clear marker when changing region
            selectedLocationView.isHidden = true
            selectedMarker?.map = nil
            selectedMarker = nil
            currentCoordinate = nil
            
            // Show clear button
            clearFilterButton.isHidden = false
            
            // Update filter button text
            let displayText = !region.arabicName.isEmpty ? region.arabicName : region.name
            updateFilterButtonConfiguration(text: displayText)
            
            // Update all polygons
            updateMapPolygons()
            
            // Animate to region bounds
            if let bounds = viewModel.getCameraBounds(for: region) {
                mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
            }
            
            // Notify delegate
            onRegionSelected?(region)
            delegate?.regionMapDidSelectRegion(region)
            
        } else {
            // Hide selected location view and clear marker
            selectedLocationView.isHidden = true
            selectedMarker?.map = nil
            selectedMarker = nil
            currentCoordinate = nil
            
            // Hide clear button
            clearFilterButton.isHidden = true
            
            // Reset filter button text
            updateFilterButtonConfiguration(text: configuration.filterButtonTitle)
            
            // Update all polygons
            updateMapPolygons()
            
            // Reset camera
            mapView.animate(to: configuration.initialCameraPosition)
        }
    }
    
    private func updateFilterButtonConfiguration(text: String) {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = .systemBlue
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.systemBlue
        ]
        config.attributedTitle = AttributedString(text, attributes: AttributeContainer(attributes))
        
        filterButton.configuration = config
    }
    
    // MARK: - Location Validation
    private func canSelectLocation(at coordinate: CLLocationCoordinate2D) -> Bool {
        // Must select a region first before placing any pin
        guard viewModel.selectedRegion != nil else {
            showMustSelectRegionFirstAlert()
            return false
        }
        
        // Check if location is within selected region
        return viewModel.isLocationInSelectedRegion(coordinate)
    }
    
    private func handleLocationTap(at coordinate: CLLocationCoordinate2D) {
        if canSelectLocation(at: coordinate) {
            // Location is valid - proceed with selection
            
            // Remove previous marker if exists
            selectedMarker?.map = nil
            
            // Create new marker
            let marker = GMSMarker(position: coordinate)
            marker.icon = GMSMarker.markerImage(with: configuration.markerColor)
            marker.map = mapView
            selectedMarker = marker
            
            // Store coordinate
            currentCoordinate = coordinate
            
            // Show selected location view
            selectedLocationView.isHidden = false
            
            // Show loading state
            addressLabel.text = "Loading address..."
            
            // Fetch address
            fetchAddress(for: coordinate)
            
        } else {
            showLocationNotAllowedAlert()
        }
    }
    
    private func fetchAddress(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                self.addressLabel.text = "Unable to fetch address"
                return
            }
            
            if let placemark = placemarks?.first {
                let address = self.formatAddress(from: placemark)
                self.addressLabel.text = address
            } else {
                self.addressLabel.text = "Address not found"
            }
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let name = placemark.name {
            addressComponents.append(name)
        }
        
        if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.isEmpty ? "Unknown Location" : addressComponents.joined(separator: ", ")
    }
    
    // MARK: - Alerts
    private func showLocationNotAllowedAlert() {
        let alert = UIAlertController(
            title: configuration.locationNotAllowedTitle,
            message: configuration.locationNotAllowedMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showMustSelectRegionFirstAlert() {
        let alert = UIAlertController(
            title: configuration.selectRegionFirstTitle,
            message: configuration.selectRegionFirstMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Select Region", style: .default, handler: { [weak self] _ in
            self?.filterButtonTapped()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Public Methods
    public func selectRegion(_ region: Region) {
        viewModel.selectRegion(region)
    }
    
    public func clearSelection() {
        viewModel.clearSelection()
    }
    
    public func getSelectedRegion() -> Region? {
        return viewModel.selectedRegion
    }
    
    public func getSelectedCoordinate() -> CLLocationCoordinate2D? {
        return currentCoordinate
    }
    
    public func getAllRegions() -> [Region] {
        return viewModel.regions
    }
}

// MARK: - RegionSelectionDelegate
extension RegionMapViewController: RegionSelectionDelegate {
    public func didSelectRegion(_ region: Region) {
        viewModel.selectRegion(region)
    }
}

// MARK: - GMSMapViewDelegate
extension RegionMapViewController: GMSMapViewDelegate {
    
    public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        handleLocationTap(at: coordinate)
    }
    
    public func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        // Handle polygon tap if needed
        if let polygon = overlay as? GMSPolygon,
           let regionName = regionPolygons.first(where: { $0.value == polygon })?.key,
           let region = viewModel.regions.first(where: { $0.name == regionName }) {
            
            if viewModel.selectedRegion == nil {
                // No filter applied, select this region
                viewModel.selectRegion(region)
            }
        }
    }
}

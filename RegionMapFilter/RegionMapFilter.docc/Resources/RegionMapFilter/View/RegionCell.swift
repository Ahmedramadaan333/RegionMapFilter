//
//  RegionCell.swift
//  RegionMapFilter
//
//  Created by Ahmed Ramadan
//  Copyright © 2024 RegionMapFilter. All rights reserved.
//

import UIKit

/// Custom table view cell for displaying region information
/// Shows primary name, secondary name (e.g. Arabic), and selection indicator
public class RegionCell: UITableViewCell {
    
    // MARK: - Properties
    public static let identifier = "RegionCell"
    
    // MARK: - UI Components
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let primaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Add subviews
        contentView.addSubview(containerStackView)
        contentView.addSubview(separatorView)
        
        // Setup stack views
        containerStackView.addArrangedSubview(textStackView)
        containerStackView.addArrangedSubview(checkmarkImageView)
        
        textStackView.addArrangedSubview(primaryLabel)
        textStackView.addArrangedSubview(secondaryLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // Checkmark image view
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Separator
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    /// Configure cell with region data
    /// - Parameter region: The region to display
    public func configure(with region: Region) {
        primaryLabel.text = region.name
        
        // Show secondary label only if secondary name exists
        if !region.arabicName.isEmpty {
            secondaryLabel.text = region.arabicName
            secondaryLabel.isHidden = false
        } else {
            secondaryLabel.isHidden = true
        }
        
        // Show checkmark if selected
        checkmarkImageView.isHidden = !region.isSelected
        
        // Update background for selection
        updateSelectionState(isSelected: region.isSelected)
    }
    
    /// Configure cell with custom text
    /// - Parameters:
    ///   - primaryText: Main text to display
    ///   - secondaryText: Secondary text (optional)
    ///   - isSelected: Whether the cell is selected
    public func configure(primaryText: String, secondaryText: String? = nil, isSelected: Bool = false) {
        primaryLabel.text = primaryText
        
        if let secondary = secondaryText, !secondary.isEmpty {
            secondaryLabel.text = secondary
            secondaryLabel.isHidden = false
        } else {
            secondaryLabel.isHidden = true
        }
        
        checkmarkImageView.isHidden = !isSelected
        updateSelectionState(isSelected: isSelected)
    }
    
    // MARK: - Styling
    
    /// Update cell appearance based on selection state
    private func updateSelectionState(isSelected: Bool) {
        if isSelected {
            contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            primaryLabel.textColor = .systemGreen
        } else {
            contentView.backgroundColor = .clear
            primaryLabel.textColor = .label
        }
    }
    
    /// Customize checkmark color
    /// - Parameter color: The color for the checkmark
    public func setCheckmarkColor(_ color: UIColor) {
        checkmarkImageView.tintColor = color
    }
    
    /// Customize primary text color
    /// - Parameter color: The color for primary text
    public func setPrimaryTextColor(_ color: UIColor) {
        primaryLabel.textColor = color
    }
    
    /// Customize secondary text color
    /// - Parameter color: The color for secondary text
    public func setSecondaryTextColor(_ color: UIColor) {
        secondaryLabel.textColor = color
    }
    
    /// Customize primary text font
    /// - Parameter font: The font for primary text
    public func setPrimaryFont(_ font: UIFont) {
        primaryLabel.font = font
    }
    
    /// Customize secondary text font
    /// - Parameter font: The font for secondary text
    public func setSecondaryFont(_ font: UIFont) {
        secondaryLabel.font = font
    }
    
    /// Hide or show separator line
    /// - Parameter hidden: Whether to hide the separator
    public func setSeparatorHidden(_ hidden: Bool) {
        separatorView.isHidden = hidden
    }
    
    /// Customize separator color
    /// - Parameter color: The color for separator
    public func setSeparatorColor(_ color: UIColor) {
        separatorView.backgroundColor = color
    }
    
    // MARK: - Cell Lifecycle
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset to defaults
        primaryLabel.text = nil
        secondaryLabel.text = nil
        secondaryLabel.isHidden = false
        checkmarkImageView.isHidden = true
        contentView.backgroundColor = .clear
        primaryLabel.textColor = .label
        secondaryLabel.textColor = .secondaryLabel
        checkmarkImageView.tintColor = .systemGreen
        separatorView.isHidden = false
    }
    
    // MARK: - Accessibility
    public override var accessibilityLabel: String? {
        get {
            var label = primaryLabel.text ?? ""
            if let secondary = secondaryLabel.text, !secondaryLabel.isHidden {
                label += ", \(secondary)"
            }
            if !checkmarkImageView.isHidden {
                label += ", Selected"
            }
            return label
        }
        set {
            super.accessibilityLabel = newValue
        }
    }
}


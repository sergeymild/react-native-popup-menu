//
//  PopMenuAction.swift
//  PopMenu
//
//  Created by Cali Castle  on 4/13/18.
//  Copyright © 2018 PopMenu. All rights reserved.
//

import UIKit

/// Type alias for selection handler.
public typealias PopMenuActionHandler = (PopMenuAction) -> Void

/// The default PopMenu action class.
public class PopMenuAction: NSObject {
    
    /// Title of action.
    public let title: String?
    
    /// Icon of action.
    public let image: UIImage?
    
    /// Image rendering option.
    public var imageRenderingMode: UIImage.RenderingMode = .alwaysTemplate
    
    /// Renderred view of action.
    public let view: UIView
    
    /// Color of action.
    public let color: Color?
    
    /// Handler of action when selected.
    public let didSelect: PopMenuActionHandler?
    
    public var rightIcon: Bool = false
    
    public var separator: PopMenuActionSeparator
    
    // MARK: - Computed Properties
    
    /// Text color of the label.
    public var tintColor: Color {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
            iconImageView.tintColor = newValue
            //backgroundColor = newValue.blackOrWhiteContrastingColor()
        }
    }
    
    /// Font for the label.
    public var font: UIFont {
        get {
            return titleLabel.font
        }
        set {
            titleLabel.font = newValue
        }
    }
    
    /// Inidcates if the action is being highlighted.
    public var highlighted: Bool = false {
        didSet {
            guard highlighted != oldValue else { return }
        }
    }
    
    /// Background color for highlighted state.
    private var backgroundColor: Color = .white

    // MARK: - Subviews
    
    /// Title label view instance.
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.text = title
        
        return label
    }()
    
    /// Icon image view instance.
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image?.withRenderingMode(imageRenderingMode)
        
        return imageView
    }()
    
    // MARK: - Initializer
    
    /// Initializer.
    public init(
        title: String? = nil,
        image: UIImage? = nil,
        color: Color? = nil,
        didSelect: PopMenuActionHandler? = nil,
        separator: PopMenuActionSeparator = .none()
    ) {
        self.title = title
        self.image = image
        self.color = color
        self.didSelect = didSelect
        self.separator = separator
        
        view = UIView()
    }
    
    /// Setup necessary views.
    fileprivate func configureViews(_ appearance: PopMenuAppearance) {
        var hasImage = false
        if let _ = image {
            hasImage = true
            view.addSubview(iconImageView)
            
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: appearance.popMenuActionIconSize),
                iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
                iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            if rightIcon {
                iconImageView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -appearance.popMenuActionPaddingHorizontal
                ).isActive = true
            } else {
                iconImageView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: appearance.popMenuActionPaddingHorizontal
                ).isActive = true
            }
        }
        
        view.addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        if rightIcon {
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: appearance.popMenuActionPaddingHorizontal
            ).isActive = true
            
            titleLabel.trailingAnchor.constraint(
                equalTo: hasImage ? iconImageView.leadingAnchor : view.trailingAnchor,
                constant: hasImage ? -8 : -appearance.popMenuActionPaddingHorizontal
            ).isActive = true
        }
        
        if !rightIcon {
            titleLabel.leadingAnchor.constraint(
                equalTo: hasImage ? iconImageView.trailingAnchor : view.leadingAnchor,
                constant: hasImage ? 8 : appearance.popMenuActionPaddingHorizontal
            ).isActive = true
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -appearance.popMenuActionPaddingHorizontal
            ).isActive = true
        }
    }

    /// Load and configure the action view.
    public func renderActionView(_ appearance: PopMenuAppearance) {
        view.layer.masksToBounds = true
        
        configureViews(appearance)
    }
    
    
    /// When the action is selected.
    public func actionSelected(animated: Bool) {
        // Trigger handler.
        didSelect?(self)
    }
    
}

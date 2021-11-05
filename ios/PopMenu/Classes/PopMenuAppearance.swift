//
//  PopMenuAppearance.swift
//  PopMenu
//
//  Created by Cali Castle on 4/13/18.
//  Copyright © 2018 PopMenu. All rights reserved.
//

import UIKit

#if os(macOS)
public typealias Color = NSColor
#else
public typealias Color = UIColor
#endif

public enum VerticalGravity {
    case bottom(CGFloat)
    case top(CGFloat)
}


public struct Shadow {
    public init(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        self.offset = offset
        self.color = color
        self.radius = radius
        self.opacity = opacity
    }
    
    let offset: CGSize
    let color: UIColor
    let radius: CGFloat
    let opacity: Float
}

/// Appearance for PopMenu.
/// Use for configuring custom styles and looks.
public struct PopMenuAppearance {
    /// Background and tint colors.
    public var popMenuColor: PopMenuColor
    
    /// The font for labels.
    public var popMenuFont: UIFont
    
    public var rightIcon: Bool
    
    public var shadow: Shadow
    
    /// Corner radius for rounded corners.
    public var popMenuCornerRadius: CGFloat
    
    /// Corner radius for rounded corners.
    public var popMenuGravityBottom: VerticalGravity
    
    /// How tall each action is.
    public var popMenuActionHeight: CGFloat
    
    /// Size of item icon
    public var popMenuActionIconSize: CGFloat

    public var popMenuActionPaddingHorizontal: CGFloat
    
    /// How many actions are the breakpoint to trigger scrollable.
    public var popMenuActionCountForScrollable: UInt

    /// The scroll indicator style when the actions are scrollable.
    public var popMenuScrollIndicatorStyle: UIScrollView.IndicatorStyle
    
    /// Hide the scroll indicator or not when the actions are scrollable.
    public var popMenuScrollIndicatorHidden: Bool

    /// The status bar style of the pop menu.
    public var popMenuStatusBarStyle: UIStatusBarStyle?
    
    /// The presentation style
    public var popMenuPresentationStyle: PopMenuPresentationStyle

    public var separator: PopMenuActionSeparator
    
    public init(
        popMenuColor: PopMenuColor = .default(),
        popMenuFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .semibold),
        rightIcon: Bool = false,
        popMenuCornerRadius: CGFloat = 24,
        popMenuGravityBottom: VerticalGravity = VerticalGravity.bottom(0),
        popMenuActionHeight: CGFloat = 50,
        popMenuActionIconSize: CGFloat = 24,
        popMenuActionPaddingHorizontal: CGFloat = 16,
        popMenuActionCountForScrollable: UInt = 6,
        popMenuScrollIndicatorStyle: UIScrollView.IndicatorStyle = .white,
        popMenuScrollIndicatorHidden: Bool = false,
        popMenuStatusBarStyle: UIStatusBarStyle? = nil,
        popMenuPresentationStyle: PopMenuPresentationStyle = .cover(),
        separator: PopMenuActionSeparator = .fill(.lightGray, height: 0.5),
        shadow: Shadow = Shadow(offset: .init(width: 0, height: 1), color: UIColor.black.withAlphaComponent(0.4), radius: 20, opacity: 0.5)
    ) {
        self.popMenuColor = popMenuColor
        self.popMenuFont = popMenuFont
        self.rightIcon = rightIcon
        self.popMenuCornerRadius = popMenuCornerRadius
        self.popMenuGravityBottom = popMenuGravityBottom
        self.popMenuActionHeight = popMenuActionHeight
        self.popMenuActionIconSize = popMenuActionIconSize
        self.popMenuActionPaddingHorizontal = popMenuActionPaddingHorizontal
        self.popMenuActionCountForScrollable = popMenuActionCountForScrollable
        self.popMenuScrollIndicatorStyle = popMenuScrollIndicatorStyle
        self.popMenuScrollIndicatorHidden = popMenuScrollIndicatorHidden
        self.popMenuStatusBarStyle = popMenuStatusBarStyle
        self.popMenuPresentationStyle = popMenuPresentationStyle
        self.separator = separator
        self.shadow = shadow
    }
}

/// Color structure for PopMenu color styles.
public struct PopMenuColor {
    
    /// Background color instance.
    public var backgroundColor: PopMenuActionBackgroundColor
    
    /// Action tint color instance.
    public var actionColor: PopMenuActionColor
    
    /// Compose the color.
    public static func configure(background: PopMenuActionBackgroundColor, action: PopMenuActionColor) -> PopMenuColor {
        return PopMenuColor(backgroundColor: background, actionColor: action)
    }
    
    /// Get default background and action color.
    public static func `default`() -> PopMenuColor {
        return PopMenuColor(
            backgroundColor: .gradient(fill: #colorLiteral(red: 0.168627451, green: 0.168627451, blue: 0.168627451, alpha: 1), #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)), actionColor: .tint(.black))
    }
    
}

/// Background color structure to control PopMenu backgrounds.
public struct PopMenuActionBackgroundColor {
    
    /// All colors (only one if solid color, or else it's gradient)
    public let colors: [Color]
    
    /// Fill an only solid color into the colors palette.
    public static func solid(fill color: Color) -> PopMenuActionBackgroundColor {
        return .init(colors: [color])
    }
    
    /// Fill gradient colors into the colors palette.
    public static func gradient(fill colors: Color...) -> PopMenuActionBackgroundColor {
        return .init(colors: colors)
    }
    
}

/// Action color structure to control PopMenu actions.
public struct PopMenuActionColor {
    
    /// Tint color.
    public let color: Color
    
    /// Get action's color instance with given color.
    public static func tint(_ color: Color) -> PopMenuActionColor {
        return PopMenuActionColor(color: color)
    }
    
}

/// Action separator structure to control PopMenu item separators.
public struct PopMenuActionSeparator: Equatable {
    
    /// Height of separator.
    public let height: CGFloat
    
    /// Color of separator.
    public let color: Color
    
    /// Fill separator color with given color and height.
    public static func fill(
        _ color: Color? = nil,
        height: CGFloat? = nil
    ) -> PopMenuActionSeparator {
        return PopMenuActionSeparator(
            height: height ?? 1,
            color: color ?? Color.lightGray.withAlphaComponent(0.5)
        )
    }
    
    /// Get separator instance with no separator style.
    public static func none() -> PopMenuActionSeparator {
        return PopMenuActionSeparator(height: 0, color: .clear)
    }
    
    /// Equatable operation.
    public static func == (lhs: PopMenuActionSeparator, rhs: PopMenuActionSeparator) -> Bool {
        return lhs.color == rhs.color && lhs.height == rhs.height
    }
    
}

///
public struct PopMenuPresentationStyle {
    
    /// The direction enum for the menu.
    public let direction: PopMenuDirection
    
    /// Custom offset coordinates.
    public let offset: CGPoint?
    
    /// The default presentation that covers the source view.
    public static func cover() -> PopMenuPresentationStyle {
        return PopMenuPresentationStyle(direction: .none, offset: nil)
    }
    
    /// The custom presentation that shows near the source view in a direction and offset.
    public static func near(_ direction: PopMenuDirection, offset: CGPoint? = nil) -> PopMenuPresentationStyle {
        return PopMenuPresentationStyle(direction: direction, offset: offset)
    }
}

public enum PopMenuDirection {
    case top
    case left
    case right
    case bottom
    case none
}

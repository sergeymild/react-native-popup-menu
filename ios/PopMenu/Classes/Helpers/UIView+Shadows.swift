//
//  UIView+Shadows.swift
//  PopMenu
//
//  Created by Cali Castle on 4/14/18.
//  Copyright © 2018 PopMenu. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Quick configuration to give the view shadows.
    public func addShadow(shadow: Shadow) {
        layer.shadowOffset = shadow.offset
        layer.shadowOpacity = shadow.opacity
        layer.shadowRadius = shadow.radius
        layer.shadowColor = shadow.color.cgColor
        layer.masksToBounds = false
    }
    
}

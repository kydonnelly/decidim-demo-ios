//
//  UIButton+Helpers.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/5/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import KTDIconFont
import UIKit

extension UIButton {
    
    func setBackgroundColor(_ backgroundColor: UIColor) {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setFillColor(backgroundColor.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.setBackgroundImage(image, for: .normal)
    }
    
}

extension UIButton {
    
    @IBInspectable
    public var iconName: String? {
        get { nil }
        set { self.setIcon(name: newValue!) }
    }

    @IBInspectable
    public var _iconColor: UIColor? {
        get { nil }
        set { self.iconColor = newValue }
    }

    @IBInspectable
    public var selectedIconName: String? {
        get { nil }
        set { self.setSelectedIcon(name: newValue!) }
    }

    @IBInspectable
    public var _selectedIconColor: UIColor? {
        get { nil }
        set { self.selectedIconColor = newValue }
    }

    @IBInspectable
    public var highlightedIconName: String? {
        get { nil }
        set { self.setHighlightedIcon(name: newValue!) }
    }

    @IBInspectable
    public var _highlightedIconColor: UIColor? {
        get { nil }
        set { self.highlightedIconColor = newValue }
    }

    @IBInspectable
    public var disabledIconName: String? {
        get { nil }
        set { self.setDisabledIcon(name: newValue!) }
    }

    @IBInspectable
    public var _disabledIconColor: UIColor? {
        get { nil }
        set { self.disabledIconColor = newValue }
    }

}

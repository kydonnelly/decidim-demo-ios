//
//  UIBarItem+Helpers.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/26/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import KTDIconFont
import UIKit

extension UIBarItem {
    
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

}

//
//  UIImageView+Helpers.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/26/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import KTDIconFont
import UIKit

extension UIImageView {
    
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
    public var _iconInset: CGFloat {
        get { 0 }
        set { self.iconInset = newValue }
    }

}

//
//  UIView+Rounded.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

extension UIView {
    
    func roundTopCorners(radius: CGFloat, addShadow: Bool) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if addShadow {
            self.layer.shadowColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1).cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: -2)
            self.layer.shadowRadius = radius
            self.layer.shadowOpacity = 0.167
        }
    }
    
}

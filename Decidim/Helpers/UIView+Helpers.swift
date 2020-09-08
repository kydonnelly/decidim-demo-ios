//
//  UIView+Helpers.swift
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

extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let cgColor = self.layer.borderColor {
                return UIColor(cgColor: cgColor)
            } else {
                return nil
            }
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            if newValue > 0 {
                self.layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowColor = UIColor(red: 0.098, green: 0.098, blue: 0.098, alpha: 1).cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowRadius = newValue
            self.layer.shadowOpacity = 0.167
            
            if newValue > 0 {
                self.layer.masksToBounds = false
            }
        }
    }
    
}

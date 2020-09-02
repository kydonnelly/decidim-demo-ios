//
//  UIColor+Helpers.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

extension UIColor {
    
    public convenience init(hexValue: UInt, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((hexValue & 0xFF00) >> 8) / 255.0,
                  blue: CGFloat(hexValue & 0xFF) / 255.0,
                  alpha: alpha)
    }
    
    public convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&hexValue)
        
        self.init(hexValue: UInt(hexValue), alpha: alpha)
    }
    
    static func randomColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random() % 256) / 256.0,
                       green: CGFloat(arc4random() % 256) / 256.0,
                       blue: CGFloat(arc4random() % 256) / 256.0,
                       alpha: 1.0)
    }
    
    static func generateColor(seed: UInt) -> UIColor {
        return UIColor(red: CGFloat(204 ^ seed * 19 % 256) / 256.0,
                       green: CGFloat(6 ^ seed * 11 % 256) / 256.0,
                       blue: CGFloat(93 ^ seed * 37 % 256) / 256.0,
                       alpha: 1.0)
    }
    
}

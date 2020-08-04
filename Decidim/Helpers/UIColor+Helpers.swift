//
//  UIColor+Helpers.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

extension UIColor {
    
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

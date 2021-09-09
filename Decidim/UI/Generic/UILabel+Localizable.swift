//
//  UILabel+Localizable.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

extension UILabel {
    
    func setPluralizableText(count: Int, singular: String, plural: String) {
        if count == 1 {
            self.text = "\(count) \(singular)"
        } else {
            self.text = "\(count) \(plural)"
        }
    }
    
}

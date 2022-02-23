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

extension UILabel {
    
    func appendIcon(_ icon: KrakenIcon) {
        guard let iconText = KrakenIcon.iconCode(for: icon) else { return }
        guard let font = self.font, let color = self.textColor else { return }
        
        let regularText = self.text?.appending(" ") ?? ""
        
        let regularAttributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        
        let iconAttributes: [NSAttributedString.Key: Any] = [.font: KrakenIcon.font(size: font.pointSize),
                                                             .foregroundColor: color]
        
        let attributedText = NSMutableAttributedString(string: regularText, attributes: regularAttributes)
        attributedText.append(NSAttributedString(string: iconText, attributes: iconAttributes))
        self.attributedText = attributedText
    }
    
}

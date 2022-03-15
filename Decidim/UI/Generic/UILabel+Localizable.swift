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
    
    func appendIcon(_ icon: VotionIcon) {
        let regularText = self.text?.appending(" ") ?? ""
        self.setText(regularText, with: icon, at: regularText.count)
    }
    
    func prependIcon(_ icon: VotionIcon) {
        let regularText: String
        if let text = self.text {
            regularText = " \(text)"
        } else {
            regularText = ""
        }
        
        self.setText(regularText, with: icon, at: 0)
    }
    
    @discardableResult
    private func setText(_ text: String, with icon: VotionIcon, at index: Int) -> Bool {
        guard let iconCode = VotionIcon.iconCode(for: icon) else { return false }
        guard let font = self.font, let color = self.textColor else { return false }
        
        let regularAttributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        
        let iconAttributes: [NSAttributedString.Key: Any] = [.font: VotionIcon.font(size: font.pointSize),
                                                             .foregroundColor: color]
        
        let iconText = NSAttributedString(string: iconCode, attributes: iconAttributes)
        let attributedText = NSMutableAttributedString(string: text, attributes: regularAttributes)
        attributedText.insert(iconText, at: index)
        
        self.attributedText = attributedText
        return true
    }
    
}

extension UIButton {
    
    func appendIcon(_ icon: VotionIcon) {
        self.titleLabel?.prependIcon(icon)
    }
    
    func prependIcon(_ icon: VotionIcon) {
        self.titleLabel?.prependIcon(icon)
    }
    
}

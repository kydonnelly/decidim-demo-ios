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

protocol IconTextElement {
    var currentFont: UIFont? { get }
    var currentText: String? { get }
    var currentTextColor: UIColor? { get }
    func setAttributedString(_ text: NSAttributedString)
}

extension IconTextElement {
    
    func appendIcon(_ icon: VotionIcon) {
        let regularText = self.currentText?.appending(" ") ?? ""
        self.setText(regularText, with: icon, at: regularText.count)
    }
    
    func prependIcon(_ icon: VotionIcon) {
        let regularText: String
        if let text = self.currentText {
            regularText = " \(text)"
        } else {
            regularText = ""
        }
        
        self.setText(regularText, with: icon, at: 0)
    }
    
    @discardableResult
    private func setText(_ text: String, with icon: VotionIcon, at index: Int) -> Bool {
        guard let iconCode = VotionIcon.iconCode(for: icon) else { return false }
        guard let font = self.currentFont, let color = self.currentTextColor else { return false }
        
        let regularAttributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        
        let iconAttributes: [NSAttributedString.Key: Any] = [.font: VotionIcon.font(size: font.pointSize),
                                                             .foregroundColor: color]
        
        let iconText = NSAttributedString(string: iconCode, attributes: iconAttributes)
        let attributedText = NSMutableAttributedString(string: text, attributes: regularAttributes)
        attributedText.insert(iconText, at: index)
        
        self.setAttributedString(attributedText)
        return true
    }
    
}

extension UILabel: IconTextElement {
    
    var currentFont: UIFont? {
        return self.font
    }
    
    var currentText: String? {
        return self.text
    }
    
    var currentTextColor: UIColor? {
        return self.textColor
    }
    
    func setAttributedString(_ text: NSAttributedString) {
        self.attributedText = text
    }
    
}

extension UIButton: IconTextElement {
    
    var currentFont: UIFont? {
        return self.titleLabel?.font
    }
    
    var currentText: String? {
        return self.titleLabel?.text
    }
    
    var currentTextColor: UIColor? {
        return self.titleLabel?.textColor
    }
    
    func setAttributedString(_ text: NSAttributedString) {
        self.setAttributedTitle(text, for: .normal)
    }
    
}

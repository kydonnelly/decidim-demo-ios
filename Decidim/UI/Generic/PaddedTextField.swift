//
//  PaddedTextField.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/1/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class PaddedTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.refreshPlaceholder(self.placeholder)
    }
    
    override var placeholder: String? {
        get {
            return self.attributedPlaceholder?.string
        }
        set {
            self.refreshPlaceholder(newValue)
        }
    }
    
    override var font: UIFont? {
        get { return super.font }
        set {
            super.font = newValue
            self.refreshPlaceholder(self.placeholder)
        }
    }
    
    override var textColor: UIColor? {
        get { return super.textColor }
        set {
            super.textColor = newValue
            self.refreshPlaceholder(self.placeholder)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 24, height: size.height + 24)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12, dy: 0)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 12, dy: 0)
    }
    
}

extension PaddedTextField {
    
    fileprivate var placeholderAttributes: [NSAttributedString.Key: Any] {
        var attrs: [NSAttributedString.Key: Any] = [:]
        if let font = self.font {
            attrs[.font] = font
        }
        if let textColor = self.textColor {
            attrs[.foregroundColor] = textColor.withAlphaComponent(0.5)
        }
        return attrs
    }
    
    private func refreshPlaceholder(_ placeholder: String?) {
        if let string = placeholder {
            self.attributedPlaceholder = NSAttributedString(string: string,
                                                            attributes: self.placeholderAttributes)
        } else {
            self.attributedPlaceholder = nil
        }
    }
    
}

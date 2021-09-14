//
//  UIButton+Loading.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/13/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

fileprivate enum AssociatedObjectKeys {
    fileprivate static var LoadingIndicatorKey: UInt8 = 0
}

extension UIButton {
    
    public var loadingIndicator: UIActivityIndicatorView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.LoadingIndicatorKey) as? UIActivityIndicatorView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.LoadingIndicatorKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func showLoading(_ isLoading: Bool) {
        if isLoading {
            guard let superview = self.superview else { return }
            
            let isBright = self.iconColor?.isBright ?? false
            let indicator = UIActivityIndicatorView(style: isBright ? .white : .gray)
            indicator.hidesWhenStopped = true
            self.loadingIndicator = indicator
            
            indicator.frame = self.frame
            indicator.backgroundColor = self.backgroundColor
            indicator.layer.cornerRadius = self.layer.cornerRadius
            indicator.layer.masksToBounds = self.layer.masksToBounds
            indicator.translatesAutoresizingMaskIntoConstraints = true
            
            self.alpha = 0.0
            superview.addSubview(indicator)
            indicator.startAnimating()
        } else if let indicator = self.loadingIndicator {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
            self.alpha = 1.0
        }
    }
    
}

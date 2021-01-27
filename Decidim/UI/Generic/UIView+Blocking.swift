//
//  UIView+Blocking.swift
//  Decidim
//
//  Created by Kyle Donnelly on 1/27/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit
import KTDIconFont

extension UIView : AssociativeObject {
    
    fileprivate static var BlockingViewKey: UInt8 = 0
    fileprivate var blockingView: UIView? {
        get { return self.getValue(key: &Self.BlockingViewKey) }
        set { self.setValue(newValue, key: &Self.BlockingViewKey) }
    }
    
    @objc func block(with blockingView: UIView) {
        self.unblock()
        
        self.blockingView = blockingView
        
        // keep above other subviews
        blockingView.layer.zPosition = 1
        blockingView.frame = self.bounds
        blockingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blockingView.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(blockingView)
    }
    
    @objc @discardableResult func unblock() -> Bool {
        guard let blockingView = self.blockingView else {
            return false
        }
        
        blockingView.removeFromSuperview()
        self.blockingView = nil
        
        return true
    }
    
    @objc fileprivate func blockingViewBounds() -> CGRect {
        return self.bounds
    }
    
}

extension UIScrollView {
    
    fileprivate static var ScrollingWasEnabledKey: UInt8 = 0
    fileprivate var scrollingWasEnabled: Bool {
        get { return (self.getValue(key: &Self.ScrollingWasEnabledKey) as NSNumber?)?.boolValue ?? false }
        set { self.setValue(NSNumber(booleanLiteral: newValue), key: &Self.ScrollingWasEnabledKey) }
    }
    
    override func block(with blockingView: UIView) {
        super.block(with: blockingView)
        
        self.scrollingWasEnabled = self.isScrollEnabled
        self.isScrollEnabled = false
    }
    
    override func unblock() -> Bool {
        let didUnblock = super.unblock()
        
        if didUnblock {
            self.isScrollEnabled = self.scrollingWasEnabled
        }
        
        return didUnblock
    }
    
    fileprivate override func blockingViewBounds() -> CGRect {
        var bounds = super.blockingViewBounds()
        
        // Block refreshing spinner if visible
        bounds.origin.x -= min(0, self.contentOffset.x + self.contentInset.left)
        bounds.origin.y -= min(0, self.contentOffset.y + self.contentInset.top)
        
        return bounds
    }
    
}

extension UIViewController {
    
    public func blockView(with blockingView: UIView) {
        self.view.block(with: blockingView)
    }
    
    public func unblockView() {
        self.view.unblock()
    }
    
}

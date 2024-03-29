//
//  UITableView+Helpers.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

extension UITableView {
    
    private var currentNoResultsView: NoResultsView? {
        return self.subviews.first { $0 is NoResultsView } as? NoResultsView
    }
    
    public func showNoResults(message: String, icon: VotionIcon, below section: Int = 0) {
        if let existing = self.currentNoResultsView {
            existing.setup(message: message, imageIcon: icon)
            return
        }
        
        let nib = UINib(nibName: "NoResultsView", bundle: .main)
        guard let view = nib.instantiate(withOwner: nil).first as? NoResultsView else {
            return
        }
        
        view.setup(message: message, imageIcon: icon)
        
        self.addSubview(view)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        self.layoutNoResultsView(below: section)
    }
    
    public func layoutNoResultsView(below section: Int = 0) {
        guard let view = self.currentNoResultsView else {
            return
        }
        
        // make sure section rects are updated
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        let inset = self.rect(forSection: section).maxY
        var frame = self.bounds
        frame.origin.y = inset
        frame.size.height -= inset
        view.frame = frame
    }
    
    public func hideNoResultsIfNeeded() {
        self.currentNoResultsView?.removeFromSuperview()
    }
    
}

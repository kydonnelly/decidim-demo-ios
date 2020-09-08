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
    
    public func showNoResults(message: String, icon: KrakenIcon = .cancel_circle, below section: Int = 0) {
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
        
        let inset = self.rect(forSection: section).minY + self.rectForHeader(inSection: section).height
        var frame = self.bounds
        frame.origin.y = inset
        frame.size.height -= inset
        view.frame = frame
    }
    
    public func hideNoResultsIfNeeded() {
        self.currentNoResultsView?.removeFromSuperview()
    }
    
}

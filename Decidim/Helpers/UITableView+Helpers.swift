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
    
    public func showNoResults(message: String, icon: KrakenIcon = .cancel_circle) {
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
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    public func hideNoResultsIfNeeded() {
        self.currentNoResultsView?.removeFromSuperview()
    }
    
}

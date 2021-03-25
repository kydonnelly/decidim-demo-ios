//
//  ActionHeaderView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/24/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ActionHeaderView: UITableViewHeaderFooterView {
    
    public typealias ActionBlock = () -> Void
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    
    private var actionBlock: ActionBlock?
    
    public func setup(title: String, action: String, onAction: ActionBlock?) {
        self.headerLabel.text = title
        self.actionButton.setTitle(action, for: .normal)
        self.actionBlock = onAction
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        self.actionBlock?()
    }
    
}

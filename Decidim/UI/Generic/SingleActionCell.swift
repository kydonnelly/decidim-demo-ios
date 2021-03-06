//
//  SingleActionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/30/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class SingleActionCell: UITableViewCell {
    
    typealias ActionBlock = (UIButton) -> Void
    
    @IBOutlet var actionButton: UIButton!
    
    private var actionBlock: ActionBlock?
    
    public func setup(action: String, isEnabled: Bool, onAction: ActionBlock?) {
        self.actionButton.setTitle(action, for: .normal)
        self.actionButton.isEnabled = isEnabled
        self.actionButton.backgroundColor = isEnabled ? .action : .lightGray
        
        self.actionBlock = onAction
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        self.actionBlock?(sender)
    }
    
}

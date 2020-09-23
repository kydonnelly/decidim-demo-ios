//
//  SettingsActionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/6/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class SettingsActionCell: CustomTableViewCell {
    
    typealias ActionBlock = () -> Void
    
    @IBOutlet var actionButton: UIButton!
    
    private var onAction: ActionBlock?
    
    public func setup(title: String, actionBlock: ActionBlock?) {
        self.actionButton.setTitle(title, for: .normal)
        self.onAction = actionBlock
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        self.onAction?()
    }
    
}

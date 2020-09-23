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
    
    private var onAction: ActionBlock?
    
    public func setup(actionBlock: ActionBlock?) {
        self.onAction = actionBlock
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        self.onAction?()
    }
    
}

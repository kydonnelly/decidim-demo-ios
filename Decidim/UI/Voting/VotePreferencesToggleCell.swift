//
//  VotePreferencesToggleCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VotePreferencesToggleCell: UITableViewCell {
    
    typealias ToggleBlock = (Bool) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var toggle: UISwitch!
    
    private var onToggle: ToggleBlock?
    
    func setup(title: String, isOn: Bool, onToggle: ToggleBlock?) {
        self.titleLabel.text = title
        self.toggle.isOn = isOn
    }
    
}

extension VotePreferencesToggleCell {
    
    @IBAction func didToggle(sender: UISwitch) {
        self.onToggle?(sender.isOn)
    }
    
}

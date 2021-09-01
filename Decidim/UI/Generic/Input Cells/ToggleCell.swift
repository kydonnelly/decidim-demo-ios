//
//  ToggleCell.swift
//  Decidim
//
//  Created by Samantha Au on 8/12/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//
import UIKit
import Foundation

class ToggleCell: CustomTableViewCell {
    
    typealias ToggleBlock = (Bool) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var toggle: UISwitch!
    
    private var onToggle: ToggleBlock?
    
    func setup(title: String, isOn: Bool, onToggle: ToggleBlock?) {
        self.titleLabel.text = title
        self.toggle.isOn = isOn
        self.onToggle = onToggle
    }
    
}

extension ToggleCell {
    
    @IBAction func didToggle(sender: UISwitch) {
        self.onToggle?(sender.isOn)
    }
    
}

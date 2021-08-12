//
//  PrivacyPreferenceToggleCell.swift
//  Decidim
//
//  Created by Samantha Au on 8/11/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//
import UIKit
import Foundation

class PrivacyPreferenceToggleCell: CustomTableViewCell {
    
    typealias ToggleBlock = (Bool) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var privateToggle: UISwitch!
    
    private var onToggle: ToggleBlock?
    
    func setup(title: String, isOn: Bool, onToggle: ToggleBlock?) {
        self.titleLabel.text = title
        self.privateToggle.isOn = isOn
        self.onToggle = onToggle
    }
    
}

extension PrivacyPreferenceToggleCell {
    
    @IBAction func didToggle(sender: UISwitch) {
        self.onToggle?(sender.isOn)
    }
    
}

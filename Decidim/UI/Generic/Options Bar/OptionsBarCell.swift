//
//  OptionsBarCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class OptionsBarCell: CustomTableViewCell {
    
    @IBOutlet var optionLabel: UILabel!
    
    public func setup(title: String, isSelected: Bool) {
        self.optionLabel.text = title
        self.optionLabel.font = UIFont.preferredFont(forTextStyle: .cta)
        self.optionLabel.textColor = isSelected ? UIColor.primaryDark : UIColor.primaryLight
    }
    
}

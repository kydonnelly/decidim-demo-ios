//
//  OptionsBarCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class OptionsBarCell: CustomTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    public func setup(title: String, isSelected: Bool) {
        self.titleLabel.text = title
        self.titleLabel.textColor = isSelected ? UIColor.action : UIColor.primaryDark
        self.titleLabel.font = UIFont.preferredFont(forTextStyle: .cta)
    }
    
}

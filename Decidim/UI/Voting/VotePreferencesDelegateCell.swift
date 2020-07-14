//
//  VotePreferencesDelegateCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VotePreferencesDelegateCell: UITableViewCell {
    
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    public func setup(category: String, profiles: [ProfileInfo]) {
        self.categoryLabel.text = category
    }
    
}

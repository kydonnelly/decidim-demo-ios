//
//  ProfilePreferencesCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfilePreferencesCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    public func setup(title: String, detail: String) {
        self.titleLabel.text = title
        self.detailLabel.text = detail
    }
    
}

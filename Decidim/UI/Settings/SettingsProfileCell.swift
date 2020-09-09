//
//  SettingsProfileCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class SettingsProfileCell: CustomTableViewCell {
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var pictureImageView: UIImageView!
    
    public func setup(profile: ProfileInfo) {
        self.handleLabel.text = profile.handle
        self.pictureImageView.image = profile.thumbnail
    }
    
}

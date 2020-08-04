//
//  ProfileSearchResultCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/29/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileSearchResultCell: UITableViewCell {
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var pictureImageView: UIImageView!
    @IBOutlet var selectedView: UIImageView!
    
    public func setup(profile: ProfileInfo, isSelected: Bool) {
        self.handleLabel.text = profile.handle
        self.pictureImageView.image = profile.thumbnail
        
        if isSelected {
            self.selectedView.image = UIImage(systemName: "circle.fill")
        } else {
            self.selectedView.image = UIImage(systemName: "circle")
        }
    }
    
}
//
//  ProfileSearchResultCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/29/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileSearchResultCell: CustomTableViewCell {
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var selectedView: UIImageView!
    @IBOutlet var pictureImageView: ThumbnailView!
    
    public func setup(profile: ProfileInfo, isSelected: Bool) {
        self.handleLabel.text = profile.handle
        self.pictureImageView.setThumbnail(url: profile.thumbnailUrl)
        
        self.selectedView.icon = isSelected ? .check : .none
        self.selectedView.borderColor = isSelected ? .clear : .detailDark
    }
    
}

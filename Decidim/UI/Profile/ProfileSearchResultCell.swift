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
    @IBOutlet var pictureImageView: GiphyMediaView!
    
    public func setup(profile: ProfileInfo, isSelected: Bool) {
        self.handleLabel.text = profile.handle
        self.pictureImageView.setThumbnail(url: profile.thumbnailUrl)
        
        self.selectedView.isHighlighted = isSelected
    }
    
}

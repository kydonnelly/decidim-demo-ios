//
//  ProfileIconCollectionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileIconCollectionCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var iconImageView: ThumbnailView!
    
    public func setup(profile: ProfileInfo) {
        self.nameLabel.text = profile.handle
        self.iconImageView.setThumbnail(url: profile.thumbnailUrl)
    }
    
}

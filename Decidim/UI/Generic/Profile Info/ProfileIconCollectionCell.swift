//
//  ProfileIconCollectionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileIconCollectionCell: UICollectionViewCell {
    
    @IBOutlet var iconImageView: UIImageView!
    
    public func setup(profile: ProfileInfo) {
        self.iconImageView.image = profile.thumbnail
    }
    
}

//
//  ProfileIconCollectionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/3/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileIconCollectionCell: UICollectionViewCell {
    
    typealias ActionBlock = () -> Void
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    private var onProfileTapped: ActionBlock?
    
    public func setup(profile: ProfileInfo, tappedProfileBlock: ActionBlock?) {
        self.iconImageView.setThumbnail(url: profile.thumbnailUrl)
        
        self.onProfileTapped = tappedProfileBlock
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfileImageView(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
    }
    
}

extension ProfileIconCollectionCell {
    
    @IBAction func tappedProfileImageView(_ sender: UIGestureRecognizer) {
        self.onProfileTapped?()
    }
    
}

//
//  ProfileNameCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileNameCell: CustomTableViewCell {
    
    typealias DelegateBlock = () -> Void
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var pictureImageView: GiphyMediaView!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    @IBOutlet var makeDelegateButton: UIButton!
    
    private var onMakeDelegateTapped: DelegateBlock?
    
    public func setup(profile: ProfileInfo, isDelegate: Bool, makeDelegateBlock: DelegateBlock?) {
        self.handleLabel.text = profile.handle
        self.pictureImageView.setThumbnail(url: profile.thumbnailUrl)
        self.gradientBackground.setupWithRandomColors(seed: profile.profileId + 1, direction: .horizontal)
        
        let delegateTitle = isDelegate ? "Remove Delegate" : "Make Delegate"
        self.makeDelegateButton.setTitle(delegateTitle, for: .normal)
        self.onMakeDelegateTapped = makeDelegateBlock
        self.makeDelegateButton.isHidden = profile.profileId == MyProfileController.shared.myProfileId
    }
    
}

extension ProfileNameCell {
    
    @IBAction func makeDelegateButtonPressed(_ sender: UIButton) {
        self.onMakeDelegateTapped?()
    }
    
}

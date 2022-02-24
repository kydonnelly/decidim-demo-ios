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
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var pictureImageView: ThumbnailView!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    @IBOutlet var makeDelegateButton: UIButton!
    @IBOutlet var makeDelegateConstraint: NSLayoutConstraint!
    
    private var onMakeDelegateTapped: DelegateBlock?
    
    public func setup(profile: ProfileInfo, isDelegate: Bool, makeDelegateBlock: DelegateBlock?) {
        self.handleLabel.text = profile.handle
        self.pictureImageView.setThumbnail(url: profile.thumbnailUrl)
        self.gradientBackground.setupWithRandomColors(seed: profile.profileId + 1, direction: .horizontal)
        
        let delegateTitle = isDelegate ? "Remove Delegate" : "Make Delegate"
        self.makeDelegateButton.setTitle(delegateTitle, for: .normal)
        self.onMakeDelegateTapped = makeDelegateBlock
        
        let isMe = profile.profileId == MyProfileController.shared.myProfileId
        self.makeDelegateButton.isHidden = isMe
        self.makeDelegateConstraint.isActive = !isMe
    }
    
}

extension ProfileNameCell {
    
    @IBAction func makeDelegateButtonPressed(_ sender: UIButton) {
        self.onMakeDelegateTapped?()
    }
    
}

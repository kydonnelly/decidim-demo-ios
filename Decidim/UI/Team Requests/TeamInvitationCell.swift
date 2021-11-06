//
//  TeamInvitationCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/28/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamInvitationCell: CustomTableViewCell {
    
    typealias CancelBlock = () -> Void
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var profileImageView: ThumbnailView!
    
    private var onCancel: CancelBlock?
    
    public func setup(profile: ProfileInfo?, cancelBlock: CancelBlock?) {
        self.handleLabel.text = profile?.handle
        self.profileImageView.setThumbnail(url: profile?.thumbnailUrl)
        
        self.onCancel = cancelBlock
    }
    
}

extension TeamInvitationCell {
    
    @IBAction func tappedCancelButton(_ sender: UIButton) {
        self.onCancel?()
    }
    
}

//
//  TeamMemberCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamMemberCell: CustomTableViewCell {
    
    typealias ManageBlock = () -> Void
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var manageButton: UIButton!
    @IBOutlet var profileImageView: ThumbnailView!
    
    private var onManage: ManageBlock?
    
    public func setup(profile: ProfileInfo?, status: TeamMemberStatus, canManage: Bool, manageBlock: ManageBlock?) {
        self.handleLabel.text = profile?.handle
        self.profileImageView.setThumbnail(url: profile?.thumbnailUrl)
        
        self.onManage = manageBlock
        self.manageButton.isHidden = !canManage
        
        switch status {
        case .requested:
            self.manageButton.setTitle("Approve", for: .normal)
        case .active:
            self.manageButton.setTitle("Ban", for: .normal)
        case .invited:
            self.manageButton.setTitle("Cancel", for: .normal)
        case .banned:
            self.manageButton.setTitle("Unban", for: .normal)
        case .unknown:
            self.manageButton.setTitle("", for: .normal)
        }
    }
    
}

extension TeamMemberCell {
    
    @IBAction func tappedManageButton(_ sender: UIButton) {
        self.onManage?()
    }
    
}

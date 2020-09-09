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
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var manageButton: UIButton!
    
    private var onManage: ManageBlock?
    
    public func setup(profile: ProfileInfo?, status: TeamMemberStatus, canManage: Bool, manageBlock: ManageBlock?) {
        self.handleLabel.text = profile?.handle
        self.profileImageView.image = profile?.thumbnail
        
        self.onManage = manageBlock
        
        switch status {
        case .requested:
            self.manageButton.setTitle("Approve", for: .normal)
        case .joined:
            self.manageButton.setTitle("Remove", for: .normal)
        case .invited:
            self.manageButton.setTitle("Uninvite", for: .normal)
        }
    }
    
}

extension TeamMemberCell {
    
    @IBAction func tappedManageButton(_ sender: UIButton) {
        self.onManage?()
    }
    
}

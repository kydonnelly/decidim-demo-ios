//
//  TeamMemberListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/18/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamMemberListCell: CustomTableViewCell {
    
    typealias InviteBlock = () -> Void
    typealias ProfileBlock = (Int) -> Void
    
    @IBOutlet var inviteButton: UIButton!
    @IBOutlet var numMembersLabel: UILabel!
    @IBOutlet var profileListView: ProfileIconListView!
    @IBOutlet var listViewConstraints: [NSLayoutConstraint]!
    
    private var inviteBlock: InviteBlock?
    
    func setup(detail: TeamDetail, inviteBlock: InviteBlock?, tappedProfileBlock: ProfileBlock?) {
        self.numMembersLabel.text = "MEMBERS: \(detail.memberList.count)"
        
        self.inviteBlock = inviteBlock
        self.inviteButton.isHidden = true

        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else { return }
            
            let allProfiles = dc.data as? [ProfileInfo] ?? []
            let allMembers = Set<Int>(detail.memberList.filter { $0.status == .active }.map { $0.user_id })
            let profiles = allProfiles.filter { allMembers.contains($0.profileId) }
            self.profileListView.setup(profiles: profiles, showAddCell: false, tappedProfileBlock: { profileId in
                tappedProfileBlock?(profileId)
            }, tappedAddBlock: nil)
            
            // todo: admins only
            if let myId = MyProfileController.shared.myProfileId {
                self.inviteButton.isHidden = !allMembers.contains(myId)
            }
            
            self.listViewConstraints.forEach { $0.isActive = allMembers.count > 0 }
        }
    }
    
    @IBAction func didTapInviteButton(_ sender: UIButton) {
        self.inviteBlock?()
    }
    
}

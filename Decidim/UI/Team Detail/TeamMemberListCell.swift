//
//  TeamMemberListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/18/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamMemberListCell: CustomTableViewCell {
    
    typealias ProfileBlock = (Int) -> Void
    
    @IBOutlet var numMembersLabel: UILabel!
    @IBOutlet var profileListView: ProfileIconListView!
    @IBOutlet var listViewConstraints: [NSLayoutConstraint]!
    
    func setup(detail: TeamDetail, tappedProfileBlock: ProfileBlock?) {
        self.numMembersLabel.text = "MEMBERS: \(detail.memberList.count)"

        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else { return }
            
            let allProfiles = dc.data as? [ProfileInfo] ?? []
            let allMembers = Set<Int>(detail.memberList.filter { $0.status == .joined }.map { $0.user_id })
            let profiles = allProfiles.filter { allMembers.contains($0.profileId) }
            self.profileListView.setup(profiles: profiles, showAddCell: false, tappedProfileBlock: { profileId in
                tappedProfileBlock?(profileId)
            }, tappedAddBlock: nil)
            
            self.listViewConstraints.forEach { $0.isActive = allMembers.count > 0 }
        }
    }
    
}

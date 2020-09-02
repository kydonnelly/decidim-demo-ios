//
//  TeamMemberListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/18/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamMemberListCell: UITableViewCell {
    
    typealias ProfileBlock = (Int) -> Void
    
    @IBOutlet var numMembersLabel: UILabel!
    @IBOutlet var profileListView: ProfileIconListView!
    @IBOutlet var listViewConstraints: [NSLayoutConstraint]!
    
    func setup(detail: TeamDetail, tappedProfileBlock: ProfileBlock?) {
        self.numMembersLabel.text = "Members: \(detail.memberList.count)"

        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else { return }
            
            let allProfiles = dc.data as? [ProfileInfo] ?? []
            let allMembers = Set<Int>(detail.memberList.compactMap { $1 == .joined ? Int($0) : nil })
            let profiles = allProfiles.filter { allMembers.contains($0.profileId) }
            self.profileListView.setup(profiles: profiles) { profileId in
                tappedProfileBlock?(profileId)
            }
            
            self.listViewConstraints.forEach { $0.isActive = allMembers.count > 0 }
        }
    }
    
}

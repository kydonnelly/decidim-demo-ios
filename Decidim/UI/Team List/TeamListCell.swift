//
//  TeamListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamListCell: CustomTableViewCell {
    
    typealias ProfileBlock = (Int) -> Void
    typealias ActionBlock = (UIButton) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var memberCountLabel: UILabel!
    @IBOutlet var iconImageView: ThumbnailView!
    
    @IBOutlet var joinActionButton: UIButton!
    
    @IBOutlet var membersListContainer: UIView!
    @IBOutlet var membersListView: ProfileIconListView!
    @IBOutlet var membersListConstraint: NSLayoutConstraint!
    
    fileprivate var onJoinTapped: ActionBlock?
    fileprivate var onOptionsTapped: ActionBlock?
    
    private var teamId: Int!
    
    public func setup(team: Team, isMember: Bool, joinBlock: ActionBlock?, profileBlock: ProfileBlock?, optionsBlock: ActionBlock?) {
        self.teamId = team.id
        
        self.titleLabel.text = team.name
        self.subtitleLabel.text = team.description
        self.iconImageView.setThumbnail(url: team.thumbnailUrl)
        self.memberCountLabel.setPluralizableText(count: team.memberCount, singular: "member", plural: "members")
        
        self.onJoinTapped = joinBlock
        self.onOptionsTapped = optionsBlock
        
        if team.isPrivate {
            self.titleLabel.appendIcon(.bubbles3)
        }
        
        self.joinActionButton.isHidden = isMember
        self.membersListContainer.isHidden = !isMember
        self.membersListConstraint.isActive = isMember
        
        if isMember {
            self.membersListView.setup(profiles: [], showAddCell: false, tappedProfileBlock: nil, tappedAddBlock: nil)
            
            TeamDetailDataController.shared(teamId: team.id).refresh { [weak self] tdc in
                guard self?.teamId == team.id else { return }
                guard let data = tdc.data as? [TeamDetail], let detail = data.first else { return }
                let activeMembers = detail.memberList.filter { $0.status == .active }.map { $0.user_id }
                
                ProfileInfoDataController.shared().refresh { [weak self] pdc in
                    guard let self = self else { return }
                    guard self.teamId == team.id else { return }
                    
                    let allProfiles = pdc.data as? [ProfileInfo] ?? []
                    let profiles = allProfiles.filter { activeMembers.contains($0.profileId) }
                    self.membersListView.setup(profiles: profiles, showAddCell: false, tappedProfileBlock: profileBlock, tappedAddBlock: nil)
                }
            }
        }
    }
    
}

extension TeamListCell {
    
    @IBAction func tappedJoinButton(_ sender: UIButton) {
        self.onJoinTapped?(sender)
    }
    
    @IBAction func tappedOptionsButton(_ sender: UIButton) {
        self.onOptionsTapped?(sender)
    }
    
}

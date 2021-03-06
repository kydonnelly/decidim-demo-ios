//
//  TeamDetailTitleCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamDetailTitleCell: CustomTableViewCell {
    
    typealias UpdateStatusBlock = (TeamMemberStatus?) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: GiphyMediaView!
    @IBOutlet var memberStatusButton: UIButton!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    private var teamDetail: TeamDetail!
    private var updateStatusBlock: UpdateStatusBlock?
    
    func setup(detail: TeamDetail, onUpdateStatus: UpdateStatusBlock?) {
        self.titleLabel.text = detail.team.name
        self.iconImageView.setThumbnail(url: detail.team.thumbnailUrl)
        self.memberStatusButton.setTitle(self.statusText(detail: detail), for: .normal)
        self.gradientBackground.setupWithRandomColors(seed: detail.team.id + 1, direction: .horizontal)
        
        self.teamDetail = detail
        self.updateStatusBlock = onUpdateStatus
    }
    
}

extension TeamDetailTitleCell {
    
    fileprivate func statusText(detail: TeamDetail) -> String {
        guard let profileId = MyProfileController.shared.myProfileId,
              let member = detail.memberList.last(where: { $0.user_id == profileId }) else {
            return "Join"
        }
        
        switch member.status {
        case .invited:
            return "Accept Invite"
        case .requested:
            return "Pending"
        case .joined:
            return "Leave"
        }
    }
    
    @IBAction func tappedMemberStatusButton(_ sender: UIButton) {
        guard let profileId = MyProfileController.shared.myProfileId else {
            return
        }
        
        let memberStatus = self.teamDetail.memberList.last { $0.user_id == profileId }?.status
        self.updateStatusBlock?(memberStatus)
    }
    
}

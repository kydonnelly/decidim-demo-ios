//
//  TeamDetailTitleCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamDetailTitleCell: UITableViewCell {
    
    typealias UpdateStatusBlock = (TeamMemberStatus?) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var memberStatusButton: UIButton!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    private var teamDetail: TeamDetail!
    private var updateStatusBlock: UpdateStatusBlock?
    
    func setup(detail: TeamDetail, onUpdateStatus: UpdateStatusBlock?) {
        self.titleLabel.text = detail.team.name
        self.iconImageView.image = detail.team.thumbnail
        self.memberStatusButton.setTitle(self.statusText(detail: detail), for: .normal)
        self.gradientBackground.setupWithRandomColors(seed: detail.team.id + 1, direction: .horizontal)
        
        self.teamDetail = detail
        self.updateStatusBlock = onUpdateStatus
    }
    
}

extension TeamDetailTitleCell {
    
    fileprivate func statusText(detail: TeamDetail) -> String {
        guard let profileId = MyProfileController.shared.myProfileId,
              let memberStatus = detail.memberList[profileId] else {
            return "Join"
        }
        
        switch memberStatus {
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
        
        let memberStatus = self.teamDetail.memberList[profileId]
        self.updateStatusBlock?(memberStatus)
    }
    
}

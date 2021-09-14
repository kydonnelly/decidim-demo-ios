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
    @IBOutlet var privacyLabel: UILabel!
    @IBOutlet var iconImageView: GiphyMediaView!
    @IBOutlet var memberStatusButton: UIButton!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    private var teamDetail: TeamDetail!
    private var updateStatusBlock: UpdateStatusBlock?
    
    func setup(detail: TeamDetail, status: TeamMemberStatus?, onUpdateStatus: UpdateStatusBlock?) {
        self.titleLabel.text = detail.team.name
        self.iconImageView.setThumbnail(url: detail.team.thumbnailUrl)
        self.privacyLabel.text = detail.team.isPrivate ? "Private" : nil
        self.memberStatusButton.setTitle(status?.actionText ?? "Request to Join", for: .normal)
        self.gradientBackground.setupWithRandomColors(seed: detail.team.id + 1, direction: .horizontal)
        
        self.teamDetail = detail
        self.updateStatusBlock = onUpdateStatus
    }
    
}

extension TeamMemberStatus {
    
    fileprivate var actionText: String {
        switch self {
        case .invited:
            return "Accept Invite"
        case .requested:
            return "Cancel Request"
        case .active:
            return "Leave"
        case .unknown:
            return "Request to Join"
        case .banned:
            return "Leave"
        }
    }
    
}

extension TeamDetailTitleCell {
    
    @IBAction func tappedMemberStatusButton(_ sender: UIButton) {
        guard let profileId = MyProfileController.shared.myProfileId else {
            return
        }
        
        let memberStatus = self.teamDetail.memberList.last { $0.user_id == profileId }?.status
        self.updateStatusBlock?(memberStatus)
    }
    
}

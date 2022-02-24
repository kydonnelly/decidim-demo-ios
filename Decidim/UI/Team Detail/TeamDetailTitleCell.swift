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
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var iconImageView: ThumbnailView!
    @IBOutlet var memberStatusButton: UIButton!
    
    private var teamDetail: TeamDetail!
    private var updateStatusBlock: UpdateStatusBlock?
    
    func setup(detail: TeamDetail, shouldExpand: Bool, status: TeamMemberStatus?, onUpdateStatus: UpdateStatusBlock?) {
        self.titleLabel.text = detail.team.name
        self.subtitleLabel.text = detail.team.description
        self.iconImageView.setThumbnail(url: detail.team.thumbnailUrl)
        self.memberStatusButton.setTitle(status?.actionText ?? "Request to Join", for: .normal)
        
        if detail.team.isPrivate {
            self.privacyLabel.text = "Private Group"
            self.privacyLabel.prependIcon(.lock_closed)
        } else {
            self.privacyLabel.text = "Public Group"
            self.privacyLabel.prependIcon(.user_group)
        }
        
        self.teamDetail = detail
        self.updateStatusBlock = onUpdateStatus
        self.subtitleLabel.numberOfLines = shouldExpand ? 0 : 2
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

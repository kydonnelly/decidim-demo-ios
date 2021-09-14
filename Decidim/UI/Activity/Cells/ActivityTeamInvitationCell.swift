//
//  ActivityTeamInvitationCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ActivityTeamInvitationCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var privacyLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity, profileRedirectBlock: ProfileBlock?) {
        guard case .teamInvitation(let member) = activity.type else { return }
        
        self.subtitleLabel.text = nil
        self.createdAtLabel.text = activity.createdDate.asShortStringAgo()
        self.privacyLabel.text = nil
        
        var asyncTeam: Team? = nil
        var asyncProfileInfo: ProfileInfo? = nil
        let updateTitleLabel: () -> Void = { [weak self] in
            if let team = asyncTeam, let profile = asyncProfileInfo {
                self?.titleLabel.text = "\(profile.handle) invited to you to join \(team.name):"
            } else if let team = asyncTeam {
                self?.titleLabel.text = "Someone invited to you to join \(team.name):"
            } else if let profile = asyncProfileInfo {
                self?.titleLabel.text = "\(profile.handle) invited you to join a team"
            } else {
                self?.titleLabel.text = "Someone invited you to join a team"
            }
        }
        
        ProfileInfoDataController.shared().refresh { dc in
            guard let infos = dc.data as? [ProfileInfo] else { return }
            guard let info = infos.first(where: { $0.profileId == member.user_id }) else { return }
            
            asyncProfileInfo = info
            updateTitleLabel()
        }
        
        TeamListDataController.shared().refresh { [weak self] dc in
            guard let self = self else { return }
            guard let teams = dc.data as? [TeamDetail] else { return }
            guard let team = teams.first(where: { $0.team.id == member.team_id }) else { return }
            
            self.subtitleLabel.text = team.team.description
            self.iconImageView.setThumbnail(url: team.team.thumbnailUrl)
            
            if team.team.isPrivate {
                self.privacyLabel.text = "Private"
                self.createdAtLabel.text?.append(" •")
            } else {
                self.privacyLabel.text = nil
            }
            
            asyncTeam = team.team
            updateTitleLabel()
        }
        
        updateTitleLabel()
    }
}

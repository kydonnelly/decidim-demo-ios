//
//  ActivityTeamDeletedCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 10/13/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ActivityTeamDeletedCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var privacyLabel: UILabel!
    
    @IBOutlet var iconImageView: ThumbnailView!
    
    func setup(activity: Activity, profileRedirectBlock: ProfileBlock?) {
        guard case .teamDeleted(let team) = activity.type else { return }
        
        self.titleLabel.text = "Team \(team.name) was deleted"
        self.subtitleLabel.text = team.description
        self.privacyLabel.text = team.isPrivate ? "Private" : nil
        
        self.iconImageView.setThumbnail(url: team.thumbnailUrl)
    }
}

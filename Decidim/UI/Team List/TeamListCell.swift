//
//  TeamListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamListCell: CustomTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var privacyLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCountLabel: UILabel!
    
    @IBOutlet var iconImageView: ThumbnailView!
    
    public func setup(team: Team) {
        self.titleLabel.text = team.name
        self.subtitleLabel.text = team.description
        self.iconImageView.setThumbnail(url: team.thumbnailUrl)
        
        
        self.createdAtLabel.text = "\(team.createdAt.asShortStringAgo()) •"
        self.memberCountLabel.setPluralizableText(count: team.memberCount, singular: "member", plural: "members")
        if team.isPrivate {
            self.privacyLabel.text = "Private"
            self.memberCountLabel.text = self.memberCountLabel.text?.appending(" •")
        } else {
            self.privacyLabel.text = nil
        }
    }
    
}

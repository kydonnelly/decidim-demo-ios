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
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    public func setup(team: Team) {
        self.titleLabel.text = team.name
        self.subtitleLabel.text = team.description
        self.iconImageView.setThumbnail(url: team.thumbnailUrl)
        
        self.createdAtLabel.text = team.createdAt.asShortStringAgo()
        self.memberCoundLabel.setPluralizableText(count: team.memberCount, singular: "member", plural: "members")
    }
    
}

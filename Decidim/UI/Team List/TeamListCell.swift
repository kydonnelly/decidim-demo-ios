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
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    public func setup(team: Team) {
        self.titleLabel.text = team.name
        self.subtitleLabel.text = team.description
        self.iconImageView.image = team.thumbnail
        
        self.createdAtLabel.text = team.createdAt.asShortStringAgo()
        self.memberCoundLabel.text = "\(team.memberCount) members"
    }
    
}

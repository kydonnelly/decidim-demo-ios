//
//  TeamDetailTitleCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamDetailTitleCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    func setup(detail: TeamDetail) {
        self.titleLabel.text = detail.team.name
        self.iconImageView.image = detail.team.thumbnail
        self.gradientBackground.update(colors: detail.gradientColors(), direction: .horizontal)
    }
    
}

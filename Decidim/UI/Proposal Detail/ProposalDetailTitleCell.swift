//
//  ProposalDetailTitleCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailTitleCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    func setup(detail: ProposalDetail) {
        self.titleLabel.text = detail.proposal.title
        self.iconImageView.image = detail.proposal.thumbnail
        self.gradientBackground.setupWithRandomColors(seed: detail.proposal.id + 1, direction: .horizontal)
    }
    
}

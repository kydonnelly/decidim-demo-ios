//
//  ProposalDetailTitleCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailTitleCell: CustomTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: GiphyMediaView!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    func setup(detail: ProposalDetail) {
        self.titleLabel.text = detail.proposal.title
        self.iconImageView.setThumbnail(url: detail.proposal.iconUrl)
        self.gradientBackground.setupWithRandomColors(seed: detail.proposal.id + 1, direction: .horizontal)
    }
    
}

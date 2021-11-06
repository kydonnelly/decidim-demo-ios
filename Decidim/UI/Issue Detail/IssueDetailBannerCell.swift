//
//  IssueDetailBannerCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueDetailBannerCell: CustomTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: ThumbnailView!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    func setup(detail: IssueDetail) {
        self.titleLabel.text = detail.issue.title
        self.iconImageView.setThumbnail(url: detail.issue.iconUrl)
        self.gradientBackground.setupWithRandomColors(seed: detail.issue.id + 1, direction: .horizontal)
    }
    
}

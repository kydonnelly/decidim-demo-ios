//
//  IssueDetailTitleCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueDetailTitleCell: CustomTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    func setup(detail: IssueDetail) {
        self.titleLabel.text = detail.issue.title
        self.iconImageView.image = detail.issue.thumbnail
        self.gradientBackground.setupWithRandomColors(seed: detail.issue.id + 1, direction: .horizontal)
    }
    
}

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
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var iconImageView: GiphyMediaView!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    func setup(detail: ProposalDetail) {
        self.titleLabel.text = detail.proposal.title
        self.gradientBackground.setupWithRandomColors(seed: detail.proposal.id + 1, direction: .horizontal)
        
        self.subtitleLabel.text = nil
        self.iconImageView.setThumbnail(url: nil)
        PublicIssueDataController.shared().refresh { [weak self] dc in
            guard let issues = dc.data as? [Issue] else {
                return
            }
            
            guard let issue = issues.first(where: { $0.id == detail.proposal.issueId }) else {
                return
            }
            
            self?.subtitleLabel.text = issue.title
            self?.iconImageView.setThumbnail(url: issue.iconUrl)
        }
    }
    
}

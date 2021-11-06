//
//  ProposalDetailTitleCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailTitleCell: CustomTableViewCell {
    
    typealias IconActionBlock = (Issue) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var iconImageView: ThumbnailView!
    @IBOutlet var gradientBackground: LinearGradientView!
    
    private var parentIssue: Issue?
    private var iconActionBlock: IconActionBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(iconImageTapped(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
    }
    
    func setup(detail: ProposalDetail, onIconAction: IconActionBlock?) {
        self.titleLabel.text = detail.proposal.title
        self.gradientBackground.setupWithRandomColors(seed: detail.proposal.id + 1, direction: .horizontal)
        
        self.iconActionBlock = onIconAction
        
        self.parentIssue = nil
        self.subtitleLabel.text = nil
        self.iconImageView.setThumbnail(url: nil)
        
        PublicIssueDataController.shared().refresh { [weak self] dc in
            guard let issues = dc.data as? [Issue] else {
                return
            }
            
            guard let issue = issues.first(where: { $0.id == detail.proposal.issueId }) else {
                return
            }
            
            self?.parentIssue = issue
            self?.subtitleLabel.text = issue.title
            self?.iconImageView.setThumbnail(url: issue.iconUrl)
        }
    }
    
}

extension ProposalDetailTitleCell {
    
    @objc func iconImageTapped(_ sender: Any) {
        guard let issue = self.parentIssue else {
            return
        }
        
        self.iconActionBlock?(issue)
    }
    
}

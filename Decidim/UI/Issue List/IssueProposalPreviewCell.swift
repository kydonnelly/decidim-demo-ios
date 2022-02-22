//
//  IssueProposalPreviewCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 2/21/22.
//  Copyright © 2022 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueProposalPreviewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var votesLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var resultsView: VotingResultsView!
    
    public func setup(proposalDetail: ProposalDetail) {
        self.titleLabel.text = proposalDetail.proposal.title
        self.subtitleLabel.text = proposalDetail.proposal.body
        self.createdAtLabel.text = "\(proposalDetail.proposal.createdAt.asShortStringAgo()) •"
        self.votesLabel.setPluralizableText(count: proposalDetail.voteCount, singular: "vote •", plural: "votes •")
        self.resultsView.setup(votes: [], expectedVoteCount: 8)
    }
    
}

extension IssueProposalPreviewCell {
    
    @IBAction func tappedHideButton(_ sender: UIButton) {
        
    }
    
}

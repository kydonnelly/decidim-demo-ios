//
//  IssueProposalPreviewCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 2/21/22.
//  Copyright © 2022 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueProposalPreviewCell: UITableViewCell {
    
    @IBOutlet var loadingCard: UIView!
    @IBOutlet var loadingResultsCard: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var votesLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var resultsView: VotingResultsView!
    
    private var proposalId: Int!
    
    public func setup(proposalId: Int) {
        self.proposalId = proposalId
        self.loadingCard.isHidden = false
        self.loadingResultsCard.isHidden = false
        
        ProposalDetailDataController.shared(proposalId: proposalId).refresh { [weak self] dc in
            guard let self = self, self.proposalId == proposalId else { return }
            guard let data = dc.data as? [ProposalDetail], let detail = data.first else { return }
            
            self.loadingCard.isHidden = true
            self.titleLabel.text = detail.proposal.title
            self.subtitleLabel.text = detail.proposal.body
            self.createdAtLabel.text = "\(detail.proposal.createdAt.asShortStringAgo()) •"
            self.votesLabel.setPluralizableText(count: detail.voteCount, singular: "vote •", plural: "votes •")
        }
        
        ProposalVotesDataController.shared(proposalId: proposalId).refresh { [weak self] dc in
            guard let self = self, self.proposalId == proposalId else { return }
            guard let dataController = dc as? ProposalVotesDataController else { return }
            
            self.loadingResultsCard.isHidden = true
            self.resultsView.setup(votes: dataController.allVotes)
        }
    }
    
}

extension IssueProposalPreviewCell {
    
    @IBAction func tappedHideButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tappedOptionsButton(_ sender: UIButton) {
        
    }
    
}

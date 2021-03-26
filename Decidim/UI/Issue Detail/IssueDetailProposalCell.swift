//
//  IssueDetailProposalCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/24/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueDetailProposalCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var deadlineLabel: UILabel!
    @IBOutlet var votingButton: UIButton!
    @IBOutlet var votingResultsView: VotingResultsView!
    
    public func setup(proposal: Proposal, votes: [ProposalVote], myVote: VoteType?) {
        self.titleLabel.text = proposal.title
        self.descriptionLabel.text = proposal.body
        self.deadlineLabel.text = Date(timeIntervalSinceNow: TimeInterval(arc4random() % 600000)).asShortStringLeft()
        
        self.votingResultsView.setup(votes: votes)
        self.votingButton.setTitle(myVote?.displayString, for: .normal)
    }
    
}

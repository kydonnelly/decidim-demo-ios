//
//  ProposalDetailVotesCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/25/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailVotingCell: UITableViewCell {
    
    @IBOutlet var voteView: VotingOptionsView!
    @IBOutlet var votingResultsView: VotingResultsView!
    
    public func setup(proposal: Proposal, votes: [ProposalVote], myVote: VoteType?, onVote: VotingOptionsView.VoteBlock?) {
        self.votingResultsView.setup(votes: votes)
        self.voteView.setup(currentVote: myVote, allVotes: votes, onVote: onVote)
    }
    
}

//
//  ProposalVoteCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalVoteCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet var votesLabel: UILabel!
    
    @IBOutlet var myVoteImage: UIImageView!
    
    public func setup(proposal: Proposal) {
        self.titleLabel.text = proposal.title
        self.subtitleLabel.text = proposal.body
        self.iconImageView.image = proposal.thumbnail
        
        self.createdAtLabel.text = proposal.createdAt.asShortStringAgo()
        self.commentsLabel.text = "\(proposal.commentCount) comments"
        self.votesLabel.text = "\(proposal.voteCount) votes"
        
        ProposalVotesDataController.shared(proposalId: proposal.id).refresh(successBlock: { [weak self] dc in
            guard let dc = dc as? ProposalVotesDataController else { return }
            
            let myVote = dc.allVotes.first { $0.authorId == 6 }
            self?.configure(voteType: myVote?.voteType)
        })
    }
    
    private func configure(voteType: VoteType?) {
        self.myVoteImage.image = voteType?.image ?? UIImage(systemName: "chevron.right")
        self.myVoteImage.tintColor = voteType?.tintColor ?? .darkGray
    }
    
}
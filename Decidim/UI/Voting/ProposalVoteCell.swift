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
        
        self.configure(voteType: VoteManager.shared.getVote(proposalId: proposal.id))
    }
    
    private func configure(voteType: VoteType?) {
        switch voteType {
        case .yes:
            self.myVoteImage.image = UIImage(systemName: "checkmark.circle.fill")
            self.myVoteImage.tintColor = .systemGreen
        case .no:
            self.myVoteImage.image = UIImage(systemName: "xmark.circle.fill")
            self.myVoteImage.tintColor = .systemRed
        case .abstain:
            self.myVoteImage.image = UIImage(systemName: "minus.circle.fill")
            self.myVoteImage.tintColor = .systemPurple
        default:
            self.myVoteImage.image = UIImage(systemName: "chevron.right")
            self.myVoteImage.tintColor = .darkGray
        }
    }
    
}

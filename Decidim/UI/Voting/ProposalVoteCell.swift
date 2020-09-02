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
    
    public func setup(proposal: Proposal, myVote: VoteType?) {
        self.titleLabel.text = proposal.title
        self.subtitleLabel.text = proposal.body
        self.iconImageView.image = proposal.thumbnail
        
        self.createdAtLabel.text = proposal.createdAt.asShortStringAgo()
        self.commentsLabel.text = "\(proposal.commentCount) comments"
        self.votesLabel.text = "\(proposal.voteCount) votes"
        
        if let vote = myVote {
            self.myVoteImage.isHidden = false
            self.myVoteImage.icon = vote.icon
            self.myVoteImage.tintColor = vote.tintColor
        } else {
            self.myVoteImage.isHidden = true
        }
    }
    
}

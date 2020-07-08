//
//  ProposalDetailEngagementCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailEngagementCell: UITableViewCell {
    
    public typealias ActionBlock = () -> Void
    
    @IBOutlet var numLikesLabel: UILabel!
    @IBOutlet var numVotesLabel: UILabel!
    @IBOutlet var numCommentsLabel: UILabel!
    
    private var likeBlock: ActionBlock!
    private var voteBlock: ActionBlock!
    private var commentBlock: ActionBlock!
    
    func setup(detail: ProposalDetail, likeBlock: ActionBlock?, voteBlock: ActionBlock?, commentBlock: ActionBlock?) {
        self.numLikesLabel.text = "\(detail.likeCount)"
        self.numVotesLabel.text = "\(detail.proposal.voteCount)"
        self.numCommentsLabel.text = "\(detail.proposal.commentCount)"
        
        self.likeBlock = likeBlock
        self.voteBlock = voteBlock
        self.commentBlock = commentBlock
    }
    
}

extension ProposalDetailEngagementCell {
    
    @IBAction func tappedLike(sender: UIButton) {
        self.likeBlock?()
    }
    
    @IBAction func tappedVote(sender: UIButton) {
        self.voteBlock?()
    }
    
    @IBAction func tappedComment(sender: UIButton) {
        self.commentBlock?()
    }
    
}

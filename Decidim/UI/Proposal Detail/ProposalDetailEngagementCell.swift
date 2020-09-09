//
//  ProposalDetailEngagementCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailEngagementCell: CustomTableViewCell {
    
    public typealias ActionBlock = () -> Void
    
    @IBOutlet var numLikesLabel: UILabel!
    @IBOutlet var numVotesLabel: UILabel!
    @IBOutlet var numCommentsLabel: UILabel!
    @IBOutlet var numAmendmentsLabel: UILabel!
    
    @IBOutlet var likeImageView: UIImageView!
    
    private var likeBlock: ActionBlock!
    private var voteBlock: ActionBlock!
    private var commentBlock: ActionBlock!
    private var amendmentBlock: ActionBlock!
    
    func setup(detail: ProposalDetail, likeBlock: ActionBlock?, voteBlock: ActionBlock?, commentBlock: ActionBlock?, amendmentBlock: ActionBlock?) {
        var likeCount = detail.likeCount
        if detail.hasLocalLike {
            likeCount += 1
        }
        
        self.likeImageView.isHighlighted = detail.hasLocalLike
        
        self.likeBlock = likeBlock
        self.voteBlock = voteBlock
        self.commentBlock = commentBlock
        self.amendmentBlock = amendmentBlock
        
        self.numLikesLabel.text = "\(likeCount)"
        self.numVotesLabel.text = "\(detail.proposal.voteCount)"
        self.numCommentsLabel.text = "\(detail.proposal.commentCount)"
        self.numAmendmentsLabel.text = "0"
        
        let proposalId = detail.proposal.id
        ProposalCommentsDataController.shared(proposalId: proposalId).refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? ProposalCommentsDataController else { return }
            let commentCount = dataController.allComments.filter { $0.proposalId == proposalId }.count
            self.numCommentsLabel.text = "\(commentCount)"
        }
        
        ProposalAmendmentDataController.shared(proposalId: proposalId).refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? ProposalAmendmentDataController else { return }
            let amendmentCount = dataController.allAmendments.filter { $0.proposalId == proposalId }.count
            self.numAmendmentsLabel.text = "\(amendmentCount)"
        }
        
        ProposalVotesDataController.shared(proposalId: proposalId).refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? ProposalVotesDataController else { return }
            let voteCount = dataController.allVotes.filter { $0.proposalId == proposalId }.count
            self.numVotesLabel.text = "\(voteCount)"
        }
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
    
    @IBAction func tappedAmendments(sender: UIButton) {
        self.amendmentBlock?()
    }
    
}

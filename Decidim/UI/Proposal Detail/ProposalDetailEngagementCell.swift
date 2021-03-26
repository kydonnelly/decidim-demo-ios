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
    @IBOutlet var numCommentsLabel: UILabel!
    
    @IBOutlet var likeImageView: UIImageView!
    
    private var likeBlock: ActionBlock!
    private var commentBlock: ActionBlock!
    
    func setup(detail: ProposalDetail, likeBlock: ActionBlock?, commentBlock: ActionBlock?) {
        var likeCount = detail.likeCount
        if detail.hasLocalLike {
            likeCount += 1
        }
        
        self.likeImageView.isHighlighted = detail.hasLocalLike
        
        self.likeBlock = likeBlock
        self.commentBlock = commentBlock
        
        self.numLikesLabel.text = "\(likeCount)"
        self.numCommentsLabel.text = "\(detail.proposal.commentCount)"
        
        let proposalId = detail.proposal.id
        ProposalCommentsDataController.shared(proposalId: proposalId).refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? ProposalCommentsDataController else { return }
            let commentCount = dataController.allComments.filter { $0.proposalId == proposalId }.count
            self.numCommentsLabel.text = "\(commentCount)"
        }
    }
    
}

extension ProposalDetailEngagementCell {
    
    @IBAction func tappedLike(sender: UIButton) {
        self.likeBlock?()
    }
    
    @IBAction func tappedComment(sender: UIButton) {
        self.commentBlock?()
    }
    
}

//
//  ProposalListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalListCell: CustomTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var issueLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var iconImageView: GiphyMediaView!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet var votesLabel: UILabel!
    
    public func setup(proposal: Proposal) {
        self.titleLabel.text = proposal.title
        self.subtitleLabel.text = proposal.body
        self.iconImageView.setThumbnail(url: nil)
        
        self.createdAtLabel.text = "\(proposal.createdAt.asShortStringAgo()) •"
        self.commentsLabel.setPluralizableText(count: proposal.commentCount, singular: "comment •", plural: "comments •")
        self.votesLabel.setPluralizableText(count: proposal.voteCount, singular: "vote", plural: "votes")
        
        PublicIssueDataController.shared().refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? PublicIssueDataController else { return }
            let parentIssue = dataController.allIssues.first { $0.id == proposal.issueId }
            
            self.issueLabel.text = parentIssue?.title
            self.iconImageView.setThumbnail(url: parentIssue?.iconUrl)
        }
        
        ProposalCommentsDataController.shared(proposalId: proposal.id).refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? ProposalCommentsDataController else { return }
            let commentCount = dataController.allComments.filter { $0.proposalId == proposal.id }.count
            self.commentsLabel.setPluralizableText(count: commentCount, singular: "comment •", plural: "comments •")
        }
        
        ProposalVotesDataController.shared(proposalId: proposal.id).refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? ProposalVotesDataController else { return }
            
            let allVotes = dataController.allVotes.filter { $0.proposalId == proposal.id }
            let voteCount = allVotes.count
            
            let nonAbstainCount = allVotes.filter { $0.voteType != .abstain }.count
            if nonAbstainCount > 0 {
                let yesCount = allVotes.filter { $0.voteType == .yes }.count
                let percentage = Int(100 * Double(yesCount) / Double(nonAbstainCount))
                self.votesLabel.setPluralizableText(count: voteCount,
                                                    singular: "vote • \(percentage)%",
                                                    plural: "votes • \(percentage)%")
            } else {
                self.votesLabel.setPluralizableText(count: voteCount, singular: "vote", plural: "votes")
            }
        }
    }
    
}

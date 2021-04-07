//
//  ProposalVoteCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalVoteCell: CustomTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var issueLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var iconImageView: GiphyMediaView!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet var votesLabel: UILabel!
    
    @IBOutlet var myVoteImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.myVoteImage.iconInset = 8
    }
    
    public func setup(proposal: Proposal, myVote: VoteType?) {
        self.titleLabel.text = proposal.title
        self.subtitleLabel.text = proposal.body
        self.iconImageView.setThumbnail(url: nil)
        
        self.createdAtLabel.text = "\(proposal.createdAt.asShortStringAgo()) •"
        self.commentsLabel.text = "\(proposal.commentCount) comments •"
        self.votesLabel.text = "\(proposal.voteCount) votes"
        
        if let vote = myVote {
            self.myVoteImage.isHidden = false
            self.myVoteImage.icon = vote.icon
            self.myVoteImage.iconColor = .primaryLight
            self.myVoteImage.iconBackgroundColor = vote.tintColor
        } else {
            self.myVoteImage.isHidden = true
        }
        
        PublicIssueDataController.shared().refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? PublicIssueDataController else { return }
            let parentIssue = dataController.allIssues.first { $0.id == proposal.issueId }
            
            self.issueLabel.text = parentIssue?.title
            self.iconImageView.setThumbnail(url: parentIssue?.iconUrl)
        }
        
        ProposalCommentsDataController.shared(proposalId: proposal.id).refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? ProposalCommentsDataController else { return }
            let commentCount = dataController.allComments.filter { $0.proposalId == proposal.id }.count
            self.commentsLabel.text = "\(commentCount) comments •"
        }
        
        ProposalVotesDataController.shared(proposalId: proposal.id).refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? ProposalVotesDataController else { return }
            
            let allVotes = dataController.allVotes.filter { $0.proposalId == proposal.id }
            let voteCount = allVotes.count
            
            let nonAbstainCount = allVotes.filter { $0.voteType != .abstain }.count
            if nonAbstainCount > 0 {
                let yesCount = allVotes.filter { $0.voteType == .yes }.count
                let percentage = Int(100 * Double(yesCount) / Double(nonAbstainCount))
                self.votesLabel.text = "\(voteCount) votes • \(percentage)%"
            } else {
                self.votesLabel.text = "\(voteCount) votes"
            }
        }
    }
    
}

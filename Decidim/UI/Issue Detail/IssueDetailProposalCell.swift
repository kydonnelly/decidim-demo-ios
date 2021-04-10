//
//  IssueDetailProposalCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/24/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueDetailProposalCell: UITableViewCell {
    
    typealias ChangeVoteBlock = (UIView) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var deadlineLabel: UILabel!
    
    @IBOutlet var votingIcon: UIImageView!
    @IBOutlet var votingButton: UIButton!
    @IBOutlet var votingContainerView: UIView!
    
    @IBOutlet var votingResultsView: VotingResultsView!
    
    private var changeVoteBlock: ChangeVoteBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeVoteTapped(_:)))
        self.votingContainerView.addGestureRecognizer(tapGesture)
    }
    
    public func setup(proposal: Proposal, votes: [ProposalVote], myVote: VoteType?, onChangeVote: ChangeVoteBlock?) {
        self.titleLabel.text = proposal.title
        self.descriptionLabel.text = proposal.body
        
        if let deadline = proposal.votingDeadline {
            self.deadlineLabel.text = deadline.asShortStringLeft()
        } else {
            self.deadlineLabel.text = "No deadline"
        }
        
        self.changeVoteBlock = onChangeVote
        
        self.votingResultsView.setup(votes: votes)
        if let vote = myVote {
            self.votingContainerView.borderColor = vote.tintColor
            self.votingContainerView.backgroundColor = vote.tintColor.withAlphaComponent(0.15)
            self.votingButton.setTitle(vote.displayString, for: .normal)
            self.votingButton.setTitleColor(.primaryDark, for: .normal)
            self.votingIcon.iconColor = vote.tintColor
            self.votingIcon.icon = vote.icon
        } else {
            self.votingContainerView.borderColor = .action
            self.votingContainerView.backgroundColor = .clear
            self.votingButton.setTitle("Vote Now", for: .normal)
            self.votingButton.setTitleColor(.action, for: .normal)
            self.votingIcon.iconColor = .action
            self.votingIcon.icon = .plus
        }
    }
    
}

extension IssueDetailProposalCell {
    
    @IBAction func changeVoteTapped(_ sender: Any) {
        self.changeVoteBlock?(self.votingContainerView)
    }
    
}

//
//  VotingResultsView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/7/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

fileprivate struct VoteSlice {
    let name: String
    let color: UIColor
    let weight: CGFloat
}

class VotingResultsView: UIView {
    
    @IBOutlet private var noPercentLabel: UILabel!
    @IBOutlet private var noImageView: UIImageView!
    @IBOutlet private var noProgressBar: VotingProgressBar!
    
    @IBOutlet private var yesPercentLabel: UILabel!
    @IBOutlet private var yesImageView: UIImageView!
    @IBOutlet private var yesProgressBar: VotingProgressBar!
    
    @IBOutlet private var abstainPercentLabel: UILabel!
    @IBOutlet private var abstainImageView: UIImageView!
    @IBOutlet private var abstainProgressBar: VotingProgressBar!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let nib = UINib(nibName: "VotingResultsView", bundle: .main)
        guard let view = nib.instantiate(withOwner: self).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        self.insertSubview(view, at: 0)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
    }
    
    public func setup(votes: [ProposalVote], expectedVoteCount: Int? = nil) {
        let totalVotes = votes.count
        let myVote = votes.first { $0.authorId == MyProfileController.shared.myProfileId }
        
        for voteType in VoteType.allCases {
            let isMyVote = myVote?.voteType == voteType
            let numVotes = votes.filter { $0.voteType == voteType }.count
            let percentage = totalVotes > 0 ? CGFloat(numVotes) / CGFloat(totalVotes) : 0
            let voteCountString = "\(numVotes) Votes"
            
            switch voteType {
            case .no:
                self.noPercentLabel.text = voteCountString
                self.noImageView.icon = isMyVote ? .check : .check_circle
                self.noProgressBar.setup(percentage: percentage, color: voteType.tintColor)
            case .yes:
                self.yesPercentLabel.text = voteCountString
                self.yesImageView.icon = isMyVote ? .check : .check_circle
                self.yesProgressBar.setup(percentage: percentage, color: voteType.tintColor)
            case .abstain:
                self.abstainPercentLabel.text = voteCountString
                self.abstainImageView.icon = isMyVote ? .check : .check_circle
                self.abstainProgressBar.setup(percentage: percentage, color: voteType.tintColor)
            }
        }
    }
    
}

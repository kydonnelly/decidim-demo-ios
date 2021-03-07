//
//  VotingResultsView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/7/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class VotingResultsView: UIView {
    
    @IBOutlet private var donutView: DonutView!
    @IBOutlet private var primaryLabel: UILabel!
    @IBOutlet private var secondaryLabel: UILabel!
    
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
        var slices: [DonutSlice] = VoteType.allCases.compactMap { voteType in
            let weight = CGFloat(votes.filter { $0.voteType == voteType }.count)
            return DonutSlice(name: voteType.rawValue, color: voteType.tintColor, weight: weight)
        }
        
        if let expectedVotes = expectedVoteCount, votes.count < expectedVotes {
            self.primaryLabel.text = "\(votes.count) / \(expectedVotes)"
            self.secondaryLabel.text = expectedVotes != 1 ? "VOTES" : "VOTE"
            
            let weight = CGFloat(expectedVotes - votes.count)
            slices.append(DonutSlice(name: "No Vote", color: .lightGray, weight: weight))
        } else {
            self.primaryLabel.text = "\(votes.count)"
            self.secondaryLabel.text = votes.count != 1 ? "VOTES" : "VOTE"
        }
        
        self.donutView.setup(slices: slices)
    }
    
}

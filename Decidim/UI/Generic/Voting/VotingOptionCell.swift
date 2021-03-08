//
//  VotingOptionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/5/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VotingOptionCell: UICollectionViewCell {
    
    @IBOutlet var voteButton: UIButton!
    @IBOutlet var selectedView: UIView!
    @IBOutlet var detailLabel: UILabel!
    
    typealias VoteBlock = () -> Void
    
    private var onVote: VoteBlock?
    
    public func setup(voteType: VoteType, percentage: CGFloat?, isSelected: Bool, onVote: VoteBlock?) {
        self.voteButton.icon = voteType.icon
        self.voteButton.iconColor = voteType.tintColor
        
        self.selectedView.isHidden = !isSelected
        
        if let percentage = percentage {
            self.detailLabel.text = "\(Int(percentage * 100))% \(voteType.displayString)"
        } else {
            self.detailLabel.text = voteType.displayString
        }
        
        self.onVote = onVote
    }
    
    @IBAction func didTapVoteButton(_ sender: UIButton) {
        self.onVote?()
    }
    
}

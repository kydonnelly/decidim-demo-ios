//
//  VotingOptionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/5/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VotingOptionCell: UICollectionViewCell {
    
    @IBOutlet var voteIcon: UIImageView!
    @IBOutlet var selectedView: UIView!
    @IBOutlet var detailLabel: UILabel!
    
    typealias VoteBlock = () -> Void
    
    private var onVote: VoteBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapVoteButton(_:)))
        self.selectedView.addGestureRecognizer(gesture)
    }
    
    public func setup(voteType: VoteType, percentage: CGFloat?, onVote: VoteBlock?) {
        self.voteIcon.icon = voteType.icon
        
        if let percentage = percentage {
            self.detailLabel.text = "\(Int(percentage * 100))% \(voteType.displayString)"
        } else {
            self.detailLabel.text = voteType.displayString
        }
        
        self.onVote = onVote
    }
    
    // For some reason selectedView.backgroundColor needs to be set on willDisplayCell
    public func refreshVote(type: VoteType, isSelected: Bool) {
        self.voteIcon.iconColor = type.tintColor
        
        if isSelected {
            self.selectedView.backgroundColor = type.tintColor.withAlphaComponent(0.15)
            self.selectedView.borderColor = type.tintColor
            self.selectedView.borderWidth = 2
        } else {
            self.selectedView.backgroundColor = .clear
            self.selectedView.borderColor = .clear
            self.selectedView.borderWidth = 0
        }
    }
    
}

extension VotingOptionCell {
    
    @IBAction func didTapVoteButton(_ sender: UITapGestureRecognizer) {
        self.onVote?()
    }
    
}

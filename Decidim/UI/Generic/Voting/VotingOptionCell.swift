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
        self.voteIcon.iconColor = isSelected ? .primaryDark : type.tintColor
        self.selectedView.backgroundColor = isSelected ? type.tintColor : .primaryBackground
    }
    
}

extension VotingOptionCell {
    
    @IBAction func didTapVoteButton(_ sender: UITapGestureRecognizer) {
        self.onVote?()
    }
    
}

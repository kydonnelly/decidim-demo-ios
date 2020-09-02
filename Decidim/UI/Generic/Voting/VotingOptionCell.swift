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
    
    typealias VoteBlock = () -> Void
    
    private var onVote: VoteBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.voteButton.iconInset = 12
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
        
        self.voteButton.cornerRadius = self.voteButton.bounds.size.height * 0.5
        self.selectedView.cornerRadius = self.selectedView.bounds.size.height * 0.5
    }
    
    public func setup(voteType: VoteType, isSelected: Bool, onVote: VoteBlock?) {
        self.voteButton.icon = voteType.icon
        self.voteButton.iconColor = .primaryLight
        self.voteButton.iconBackgroundColor = voteType.tintColor
        
        self.selectedView.borderWidth = isSelected ? 4 : 0
        
        self.onVote = onVote
    }
    
    @IBAction func didTapVoteButton(_ sender: UIButton) {
        self.onVote?()
    }
    
}

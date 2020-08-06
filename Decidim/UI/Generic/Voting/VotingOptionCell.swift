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
    
    typealias VoteBlock = () -> Void
    
    private var onVote: VoteBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.voteButton.tintColor = .white
        self.voteButton.layer.cornerRadius = 36
        self.voteButton.layer.masksToBounds = true
        self.voteButton.layer.borderColor = UIColor.red.cgColor
    }
    
    public func setup(voteType: VoteType, isSelected: Bool, onVote: VoteBlock?) {
        self.voteButton.setImage(voteType.image, for: .normal)
        self.voteButton.setBackgroundColor(voteType.tintColor)
        
        self.voteButton.layer.borderWidth = isSelected ? 2.0 : 0.0
        
        self.onVote = onVote
    }
    
    @IBAction func didTapVoteButton(_ sender: UIButton) {
        self.onVote?()
    }
    
}

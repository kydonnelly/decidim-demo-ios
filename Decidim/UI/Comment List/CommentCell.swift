//
//  CommentCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class CommentCell: CustomTableViewCell {
    
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var reactButton: UIButton!
    @IBOutlet var optionsButton: UIButton!
    
    typealias ProfileBlock = () -> Void
    typealias OptionsBlock = (UIButton) -> Void
    
    fileprivate var onOptionsTapped: OptionsBlock?
    fileprivate var onProfileTapped: ProfileBlock?
    
    func setup(comment: ProposalComment, isOwn: Bool, isExpanded: Bool, isEditing: Bool, optionsBlock: OptionsBlock?, tappedProfileBlock: ProfileBlock?) {
        self.commentLabel.text = comment.text
        self.handleLabel.text = "Unknown Commenter"
        self.timeLabel.text = comment.createdAt.asShortStringAgo()
        
        self.commentLabel.numberOfLines = isExpanded ? 0 : 2
        
        self.reactButton.isHidden = isOwn
        self.optionsButton.isHidden = !isOwn
        
        self.onOptionsTapped = optionsBlock
        self.onProfileTapped = tappedProfileBlock
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfileImageView(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
        
        self.contentView.backgroundColor = isEditing ? UIColor.action.withAlphaComponent(0.1) : .clear
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else {
                return
            }
            guard let infos = dc.data as? [ProfileInfo] else {
                return
            }
            guard let info = infos.first(where: { $0.profileId == comment.authorId }) else {
                return
            }
            
            self.handleLabel.text = info.handle
            self.iconImageView.image = info.thumbnail
        }
    }
    
}

extension CommentCell {
    
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        self.onOptionsTapped?(sender)
    }
    
    @IBAction func tappedProfileImageView(_ sender: UIGestureRecognizer) {
        self.onProfileTapped?()
    }
    
}

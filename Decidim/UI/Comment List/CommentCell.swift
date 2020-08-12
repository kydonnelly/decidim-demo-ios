//
//  CommentCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var reactButton: UIButton!
    @IBOutlet var optionsButton: UIButton!
    
    typealias OptionsBlock = (UIButton) -> Void
    
    fileprivate var onOptionsTapped: OptionsBlock?
    
    func setup(comment: ProposalComment, isOwn: Bool, isEditing: Bool, optionsBlock: OptionsBlock?) {
        self.commentLabel.text = comment.text
        self.handleLabel.text = "Unknown Commenter"
        self.timeLabel.text = comment.createdAt.asShortStringAgo()
        
        self.reactButton.isHidden = isOwn
        self.optionsButton.isHidden = !isOwn
        
        self.onOptionsTapped = optionsBlock
        
        self.contentView.backgroundColor = isEditing ? UIColor.purple.withAlphaComponent(0.1) : .clear
        
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
    
}

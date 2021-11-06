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
    @IBOutlet var iconImageView: ThumbnailView!
    
    @IBOutlet var replyButton: UIButton!
    @IBOutlet var optionsButton: UIButton!
    
    typealias ProfileBlock = () -> Void
    typealias OptionsBlock = (UIButton) -> Void
    typealias ReplyBlock = (ProfileInfo?) -> Void
    
    fileprivate var onReplyTapped: ReplyBlock?
    fileprivate var onOptionsTapped: OptionsBlock?
    fileprivate var onProfileTapped: ProfileBlock?
    
    fileprivate var profileInfo: ProfileInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfileImageView(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
    }
    
    func setup(comment: Comment, isOwn: Bool, isExpanded: Bool, isEditing: Bool, replyBlock: ReplyBlock?, optionsBlock: OptionsBlock?, tappedProfileBlock: ProfileBlock?) {
        self.commentLabel.text = comment.text
        self.handleLabel.text = "Unknown Commenter"
        self.timeLabel.text = " • \(comment.createdAt.asShortStringAgo())"
        
        self.commentLabel.numberOfLines = isExpanded ? 0 : 2
        
        self.replyButton.isHidden = isOwn
        self.optionsButton.isHidden = !isOwn
        
        self.onReplyTapped = replyBlock
        self.onOptionsTapped = optionsBlock
        self.onProfileTapped = tappedProfileBlock
        
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
            
            self.profileInfo = info
            self.handleLabel.text = info.handle
            self.iconImageView.setThumbnail(url: info.thumbnailUrl)
        }
    }
    
}

extension CommentCell {
    
    @IBAction func replyButtonTapped(_ sender: UIButton) {
        self.onReplyTapped?(self.profileInfo)
    }
    
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        self.onOptionsTapped?(sender)
    }
    
    @IBAction func tappedProfileImageView(_ sender: UIGestureRecognizer) {
        self.onProfileTapped?()
    }
    
}

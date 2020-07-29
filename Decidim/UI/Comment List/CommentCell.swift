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
    
    func setup(comment: ProposalComment) {
        self.commentLabel.text = comment.text
        self.handleLabel.text = "Unknown Commenter"
        self.timeLabel.text = comment.timestamp.asShortStringAgo()
        
        ProfileInfoDataController.shared().refresh { dc in
            guard let infos = dc.data as? [ProfileInfo] else {
                return
            }
            guard let info = infos.first(where: { $0.profileId == comment.authorId }) else {
                return
            }
            
            self.handleLabel.text = info.handle
        }
    }
    
}

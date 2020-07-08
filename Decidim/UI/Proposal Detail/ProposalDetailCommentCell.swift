//
//  ProposalDetailCommentCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailCommentCell: UITableViewCell {
    
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    func setup(comment: ProposalComment) {
        self.commentLabel.text = comment.text
        self.handleLabel.text = "Commenter \(comment.authorId)"
    }
    
}

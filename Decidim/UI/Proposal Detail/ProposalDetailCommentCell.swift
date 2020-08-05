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
    
    typealias OptionsBlock = (UIButton) -> Void
    
    fileprivate var optionsBlock: OptionsBlock?
    
    func setup(comment: ProposalComment, optionsBlock: OptionsBlock?) {
        self.commentLabel.text = comment.text
        self.handleLabel.text = "Unknown Commenter"
        
        self.optionsBlock = optionsBlock
        
        ProfileInfoDataController.shared().refresh { dc in
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
    
    @IBAction func optionsButtonPressed(_ sender: UIButton) {
        self.optionsBlock?(sender)
    }
    
}

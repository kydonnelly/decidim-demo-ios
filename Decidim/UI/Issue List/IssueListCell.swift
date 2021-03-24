//
//  IssueListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueListCell: CustomTableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    
    public func setup(issue: Issue) {
        self.titleLabel.text = issue.title
        self.subtitleLabel.text = issue.body
        self.iconImageView.image = issue.thumbnail
        
        self.createdAtLabel.text = "\(issue.createdAt.asShortStringAgo()) •"
        self.commentsLabel.text = "\(issue.commentCount) comments"
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else {
                return
            }
            guard let infos = dc.data as? [ProfileInfo] else {
                return
            }
            guard let info = infos.first(where: { $0.profileId == issue.authorId }) else {
                return
            }
            
            self.authorLabel.text = info.handle
        }
        
        IssueCommentsDataController.shared(issueId: issue.id).refresh { [weak self] dc in
            guard let self = self, let dataController = dc as? IssueCommentsDataController else { return }
            let commentCount = dataController.allComments.filter { $0.issueId == issue.id }.count
            self.commentsLabel.text = "\(commentCount) comments"
        }
    }
    
}

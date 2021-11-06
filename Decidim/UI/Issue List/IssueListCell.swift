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
    @IBOutlet var iconImageView: ThumbnailView!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    
    public func setup(issue: Issue) {
        self.titleLabel.text = issue.title
        self.subtitleLabel.text = issue.body
        self.iconImageView.setThumbnail(url: issue.iconUrl)
        
        self.createdAtLabel.text = "\(issue.createdAt.asShortStringAgo()) •"
        self.commentsLabel.setPluralizableText(count: issue.commentCount, singular: "comment", plural: "comments")
        
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
            self.commentsLabel.setPluralizableText(count: commentCount, singular: "comment", plural: "comments")
        }
    }
    
}

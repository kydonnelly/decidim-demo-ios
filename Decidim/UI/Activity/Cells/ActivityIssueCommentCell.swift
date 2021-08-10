//
//  ActivityIssueCommentCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ActivityIssueCommentCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var iconImageView: GiphyMediaView!
    
    fileprivate var onProfileTapped: (() -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfileImageView(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
    }
    
    func setup(activity: Activity, profileRedirectBlock: ProfileBlock?) {
        guard case .issueComment(let comment) = activity.type else { return }
        
        self.onProfileTapped = {
            profileRedirectBlock?(comment.authorId)
        }
        
        self.commentLabel.text = comment.text
        self.timeLabel.text = activity.createdDate.asShortStringAgo()
        
        var asyncIssue: Issue? = nil
        var asyncProfileInfo: ProfileInfo? = nil
        let updateTitleLabel: () -> Void = { [weak self] in
            if let issue = asyncIssue, let profile = asyncProfileInfo {
                self?.handleLabel.text = "\(profile.handle) commented on your topic \(issue.title):"
            } else if let issue = asyncIssue {
                self?.handleLabel.text = "Someone commented on your topic \(issue.title):"
            } else if let profile = asyncProfileInfo {
                self?.handleLabel.text = "\(profile.handle) commented on your topic:"
            } else {
                self?.handleLabel.text = "Someone commented on your topic"
            }
        }
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else { return }
            guard let infos = dc.data as? [ProfileInfo] else { return }
            guard let info = infos.first(where: { $0.profileId == comment.authorId }) else { return }
            
            self.iconImageView.setThumbnail(url: info.thumbnailUrl)
            
            asyncProfileInfo = info
            updateTitleLabel()
        }
        
        PublicIssueDataController.shared().refresh { dc in
            guard let issues = dc.data as? [Issue] else { return }
            guard let issue = issues.first(where: { $0.id == comment.issueId }) else { return }
            
            asyncIssue = issue
            updateTitleLabel()
        }
        
        updateTitleLabel()
    }
    
}

extension ActivityIssueCommentCell {
    
    @IBAction func tappedProfileImageView(_ sender: UIGestureRecognizer) {
        self.onProfileTapped?()
    }
    
}

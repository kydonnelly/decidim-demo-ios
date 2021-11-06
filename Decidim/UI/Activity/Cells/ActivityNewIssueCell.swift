//
//  ActivityNewIssueCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ActivityNewIssueCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    
    @IBOutlet var iconImageView: ThumbnailView!
    
    func setup(activity: Activity, profileRedirectBlock: ProfileBlock?) {
        guard case .newIssue(let issue) = activity.type else { return }
        
        self.titleLabel.text = "Somoeone created a new topic: \(issue.title)"
        self.subtitleLabel.text = issue.body
        self.iconImageView.setThumbnail(url: issue.iconUrl)
        
        self.createdAtLabel.text = activity.createdDate.asShortStringAgo()
        
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
            
            self.titleLabel.text = "\(info.handle) created a new topic: \(issue.title)"
        }
    }
}

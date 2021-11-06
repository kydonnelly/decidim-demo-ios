//
//  ActivityAmendmentDeadlineCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ActivityAmendmentDeadlineCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    
    @IBOutlet var iconImageView: ThumbnailView!
    
    fileprivate var onProfileTapped: (() -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfileImageView(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
    }
    
    func setup(activity: Activity, profileRedirectBlock: ProfileBlock?) {
        guard case .amendmentDeadline(let proposal) = activity.type else { return }
        
        self.titleLabel.text = "Last call for amendments on the idea: \(proposal.title)"
        self.subtitleLabel.text = proposal.body
        self.createdAtLabel.text = activity.createdDate.asShortStringAgo()
        
        self.onProfileTapped = {
            profileRedirectBlock?(proposal.authorId)
        }
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else {
                return
            }
            guard let infos = dc.data as? [ProfileInfo] else {
                return
            }
            guard let info = infos.first(where: { $0.profileId == proposal.authorId }) else {
                return
            }
            
            self.titleLabel.text = "Last call for amendments on \(info.handle)'s idea: \(proposal.title)"
            self.iconImageView.setThumbnail(url: info.thumbnailUrl)
        }
    }
}

extension ActivityAmendmentDeadlineCell {
    
    @IBAction func tappedProfileImageView(_ sender: UIGestureRecognizer) {
        self.onProfileTapped?()
    }
    
}

//
//  ActivityVotingDeadlineCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ActivityVotingDeadlineCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var createdAtLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    fileprivate var onProfileTapped: (() -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfileImageView(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
    }
    
    func setup(activity: Activity, profileRedirectBlock: ProfileBlock?) {
        guard case .votingDeadline(let proposal) = activity.type else { return }
        
        self.subtitleLabel.text = proposal.body
        self.createdAtLabel.text = activity.createdDate.asShortStringAgo()
        
        self.onProfileTapped = {
            profileRedirectBlock?(proposal.authorId)
        }
        
        var asyncIssue: Issue? = nil
        var asyncProfileInfo: ProfileInfo? = nil
        let updateTitleLabel: () -> Void = { [weak self] in
            if let issue = asyncIssue, let profile = asyncProfileInfo {
                self?.titleLabel.text = "Voting has started in the topic \"\(issue.title)\" on \(profile.handle)'s idea \(proposal.title)"
            } else if let issue = asyncIssue {
                self?.titleLabel.text = "Voting has started in the topic \"\(issue.title)\" on the idea \(proposal.title)"
            } else if let profile = asyncProfileInfo {
                self?.titleLabel.text = "Voting has started on \(profile.handle)'s idea: \(proposal.title)"
            } else {
                self?.titleLabel.text = "Voting has started on the idea: \(proposal.title)"
            }
        }
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else { return }
            guard let infos = dc.data as? [ProfileInfo] else { return }
            guard let info = infos.first(where: { $0.profileId == proposal.authorId }) else { return }
            
            self.iconImageView.setThumbnail(url: info.thumbnailUrl)
            asyncProfileInfo = info
            updateTitleLabel()
        }
        
        PublicIssueDataController.shared().refresh { dc in
            guard let issues = dc.data as? [Issue] else { return }
            guard let issue = issues.first(where: { $0.id == proposal.issueId }) else { return }
            
            asyncIssue = issue
            updateTitleLabel()
        }
        
        updateTitleLabel()
    }
}

extension ActivityVotingDeadlineCell {
    
    @IBAction func tappedProfileImageView(_ sender: UIGestureRecognizer) {
        self.onProfileTapped?()
    }
    
}

//
//  ActivityCommentCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ActivityCommentCell: UITableViewCell, ActivityCell {
    
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
        guard case .comment(let comment) = activity.type else { return }
        
        self.onProfileTapped = {
            profileRedirectBlock?(comment.authorId)
        }
        
        self.commentLabel.text = comment.text
        self.timeLabel.text = activity.createdDate.asShortStringAgo()
        
        var asyncProposal: Proposal? = nil
        var asyncProfileInfo: ProfileInfo? = nil
        let updateTitleLabel: () -> Void = { [weak self] in
            if let proposal = asyncProposal, let profile = asyncProfileInfo {
                self?.handleLabel.text = "\(profile.handle) commented on your idea \(proposal.title):"
            } else if let proposal = asyncProposal {
                self?.handleLabel.text = "Someone commented on your idea \(proposal.title):"
            } else if let profile = asyncProfileInfo {
                self?.handleLabel.text = "\(profile.handle) commented on your idea:"
            } else {
                self?.handleLabel.text = "Someone commented on your idea"
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
        
        PublicProposalDataController.shared().refresh { dc in
            guard let proposals = dc.data as? [Proposal] else { return }
            guard let proposal = proposals.first(where: { $0.id == comment.proposalId }) else { return }
            
            asyncProposal = proposal
            updateTitleLabel()
        }
        
        updateTitleLabel()
    }
    
}

extension ActivityCommentCell {
    
    @IBAction func tappedProfileImageView(_ sender: UIGestureRecognizer) {
        self.onProfileTapped?()
    }
    
}

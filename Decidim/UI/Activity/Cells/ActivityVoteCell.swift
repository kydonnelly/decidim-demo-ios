//
//  ActivityVoteCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ActivityVoteCell: UITableViewCell, ActivityCell {
    
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
        guard case .vote(let vote) = activity.type else { return }
        
        self.onProfileTapped = {
            profileRedirectBlock?(vote.authorId)
        }
        
        self.subtitleLabel.text = "They voted like \(vote.voteType.rawValue)"
        self.createdAtLabel.text = activity.createdDate.asShortStringAgo()
        
        var asyncProposal: Proposal? = nil
        var asyncProfileInfo: ProfileInfo? = nil
        let updateTitleLabel: () -> Void = { [weak self] in
            if let proposal = asyncProposal, let profile = asyncProfileInfo {
                self?.titleLabel.text = "\(profile.handle) voted on your idea \(proposal.title):"
            } else if let proposal = asyncProposal {
                self?.titleLabel.text = "Someone voted on your idea \(proposal.title):"
            } else if let profile = asyncProfileInfo {
                self?.titleLabel.text = "\(profile.handle) voted on your idea:"
            } else {
                self?.titleLabel.text = "Someone voted on your idea:"
            }
        }
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else { return }
            guard let infos = dc.data as? [ProfileInfo] else { return }
            guard let info = infos.first(where: { $0.profileId == vote.authorId }) else { return }
            
            self.iconImageView.setThumbnail(url: info.thumbnailUrl)
            
            asyncProfileInfo = info
            updateTitleLabel()
        }
        
        PublicProposalDataController.shared().refresh { dc in
            guard let proposals = dc.data as? [Proposal] else { return }
            guard let proposal = proposals.first(where: { $0.id == vote.proposalId }) else { return }
            
            asyncProposal = proposal
            updateTitleLabel()
        }
        
        updateTitleLabel()
    }
}

extension ActivityVoteCell {
    
    @IBAction func tappedProfileImageView(_ sender: UIGestureRecognizer) {
        self.onProfileTapped?()
    }
    
}

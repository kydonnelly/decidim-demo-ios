//
//  ProposalVoterCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/2/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalVoterCell: CustomTableViewCell {
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var delegateLabel: UILabel!
    @IBOutlet var voteImage: UIImageView!
    @IBOutlet var profileImageView: ThumbnailView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.voteImage.iconInset = 8
    }
    
    public func setup(vote: ProposalVote) {
        self.delegateLabel.text = nil
        self.timeLabel.text = vote.createdAt.asShortStringAgo()
        
        self.voteImage.icon = vote.voteType.icon
        self.voteImage.iconColor = vote.voteType.tintColor
        self.voteImage.borderColor = vote.voteType.tintColor
        self.voteImage.iconBackgroundColor = vote.voteType.tintColor.withAlphaComponent(0.15)
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else {
                return
            }
            guard let infos = dc.data as? [ProfileInfo] else {
                return
            }
            guard let info = infos.first(where: { $0.profileId == vote.authorId }) else {
                return
            }
            
            self.handleLabel.text = info.handle
            self.profileImageView.setThumbnail(url: info.thumbnailUrl)
            
            if let delegateId = vote.delegateId,
               let delegate = infos.first(where: { $0.profileId == delegateId }) {
                self.delegateLabel.text = "delegated via @\(delegate.handle)"
            }
        }
    }
    
}

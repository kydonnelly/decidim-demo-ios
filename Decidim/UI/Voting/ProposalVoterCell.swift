//
//  ProposalVoterCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/2/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalVoterCell: UITableViewCell {
    
    @IBOutlet var voteImage: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    public func setup(vote: ProposalVote) {
        self.timeLabel.text = vote.createdAt.asShortStringAgo()
        
        self.voteImage.image = vote.voteType.image
        self.voteImage.tintColor = vote.voteType.tintColor
        
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
            self.profileImageView.image = info.thumbnail
        }
    }
    
}

//
//  AmendmentCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/4/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class AmendmentCell: UITableViewCell {
    
    @IBOutlet var amendmentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var statusImageView: UIImageView!
    
    func setup(amendment: ProposalAmendment) {
        self.amendmentLabel.text = amendment.text
        self.timeLabel.text = amendment.createdAt.asShortStringAgo()
        
        self.statusImageView.image = amendment.status.image
        self.statusImageView.tintColor = amendment.status.tintColor
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else {
                return
            }
            guard let infos = dc.data as? [ProfileInfo] else {
                return
            }
            guard let info = infos.first(where: { $0.profileId == amendment.authorId }) else {
                return
            }
            
            self.handleLabel.text = info.handle
            self.iconImageView.image = info.thumbnail
        }
    }
    
}

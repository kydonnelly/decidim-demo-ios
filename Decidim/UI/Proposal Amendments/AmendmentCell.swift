//
//  AmendmentCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/4/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class AmendmentCell: CustomTableViewCell {
    
    typealias ActionBlock = () -> Void
    
    @IBOutlet var amendmentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var iconImageView: GiphyMediaView!
    
    @IBOutlet var statusImageView: UIImageView!
    
    private var onProfileTapped: ActionBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusImageView.iconInset = 8
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedProfileImageView(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
    }
    
    func setup(amendment: ProposalAmendment, tappedProfileBlock: ActionBlock?) {
        self.amendmentLabel.text = amendment.text
        self.timeLabel.text = amendment.createdAt.asShortStringAgo()
        
        self.statusImageView.icon = amendment.status.icon
        self.statusImageView.iconColor = .primaryLight
        self.statusImageView.iconBackgroundColor = amendment.status.tintColor
        
        self.onProfileTapped = tappedProfileBlock
        
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
            self.iconImageView.setThumbnail(url: info.thumbnailUrl)
        }
    }
    
}

extension AmendmentCell {
    
    @IBAction func tappedProfileImageView(_ sender: UIGestureRecognizer) {
        self.onProfileTapped?()
    }
    
}

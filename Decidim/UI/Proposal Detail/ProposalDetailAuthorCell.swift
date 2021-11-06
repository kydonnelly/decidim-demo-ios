//
//  ProposalDetailAuthorCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailAuthorCell: CustomTableViewCell {
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var iconImageView: ThumbnailView!
    
    func setup(detail: ProposalDetail) {
        self.handleLabel.text = "Unknown Proposer"
        
        ProfileInfoDataController.shared().refresh { dc in
            guard let infos = dc.data as? [ProfileInfo] else {
                return
            }
            guard let info = infos.first(where: { $0.profileId == detail.proposal.authorId }) else {
                return
            }
            
            self.handleLabel.text = info.handle
            self.iconImageView.setThumbnail(url: info.thumbnailUrl)
        }
    }
    
}

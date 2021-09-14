//
//  TeamInviteCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/28/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamInviteCell: CustomTableViewCell {
    
    typealias ResponseBlock = (Bool) -> Void
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var privacyLabel: UILabel!
    @IBOutlet var teamImageView: GiphyMediaView!
    
    private var onResponse: ResponseBlock?
    
    public func setup(detail: TeamDetail, responseBlock: ResponseBlock?) {
        self.nameLabel.text = detail.team.name
        self.privacyLabel.text = detail.team.isPrivate ? "Private" : nil
        self.teamImageView.setThumbnail(url: detail.previewThumbnailUrl)
        
        self.onResponse = responseBlock
    }
    
}

extension TeamInviteCell {
    
    @IBAction func tappedApproveButton(_ sender: UIButton) {
        self.onResponse?(true)
    }
    
    @IBAction func tappedRejectButton(_ sender: UIButton) {
        self.onResponse?(false)
    }
    
}

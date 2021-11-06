//
//  TeamJoinRequestCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/16/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamJoinRequestCell: CustomTableViewCell {
    
    typealias CancelBlock = () -> Void
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImageView: ThumbnailView!
    
    private var onCancel: CancelBlock?
    
    public func setup(team: Team, cancelBlock: CancelBlock?) {
        self.nameLabel.text = team.name
        self.profileImageView.setThumbnail(url: team.thumbnailUrl)
        
        self.onCancel = cancelBlock
    }
    
}

extension TeamJoinRequestCell {
    
    @IBAction func tappedCancelButton(_ sender: UIButton) {
        self.onCancel?()
    }
    
}

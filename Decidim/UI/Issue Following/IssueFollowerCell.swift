//
//  IssueFollowerCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 4/10/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueFollowerCell: CustomTableViewCell {
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var profileImageView: GiphyMediaView!
    
    public func setup(profile: ProfileInfo?) {
        self.handleLabel.text = profile?.handle
        self.profileImageView.setThumbnail(url: profile?.thumbnailUrl)
    }
    
}

//
//  TeamMemberRequestCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/16/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class MemberJoinRequestCell: CustomTableViewCell {
    
    typealias ResponseBlock = (Bool) -> Void
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var profileImageView: GiphyMediaView!
    
    private var onResponse: ResponseBlock?
    
    public func setup(profile: ProfileInfo?, responseBlock: ResponseBlock?) {
        self.handleLabel.text = profile?.handle
        self.profileImageView.setThumbnail(url: profile?.thumbnailUrl)
        
        self.onResponse = responseBlock
    }
    
}

extension MemberJoinRequestCell {
    
    @IBAction func tappedApproveButton(_ sender: UIButton) {
        self.onResponse?(true)
    }
    
    @IBAction func tappedRejectButton(_ sender: UIButton) {
        self.onResponse?(false)
    }
    
}

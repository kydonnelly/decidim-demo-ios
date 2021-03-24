//
//  IssueDetailEngagementCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueDetailEngagementCell: CustomTableViewCell {
    
    public typealias ActionBlock = () -> Void
    
    @IBOutlet var myFollowingLabel: UILabel!
    @IBOutlet var numFollowersLabel: UILabel!
    
    @IBOutlet var followImageView: UIImageView!
    
    private var followBlock: ActionBlock!
    private var allFollowersBlock: ActionBlock!
    
    func setup(detail: IssueDetail, followBlock: ActionBlock?, allFollowersBlock: ActionBlock?) {
        var isFollowing = detail.userIsFollowing
        var followCount = detail.followersCount
        if detail.hasLocalFollow {
            followCount += 1
            isFollowing = true
        }
        
        self.followImageView.isHighlighted = isFollowing
        
        self.followBlock = followBlock
        self.allFollowersBlock = allFollowersBlock
        
        self.numFollowersLabel.text = "\(followCount) Followers"
        self.myFollowingLabel.text = isFollowing ? "Following" : "Follow"
    }
    
}

extension IssueDetailEngagementCell {
    
    @IBAction func tappedFollowers(sender: UIButton) {
        self.allFollowersBlock?()
    }
    
    @IBAction func tappedFollow(sender: UIButton) {
        self.followBlock?()
    }
    
}

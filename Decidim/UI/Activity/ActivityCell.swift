//
//  ActivityCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

protocol ActivityCell: UITableViewCell {
    func setup(activity: Activity)
}

class ActivityCommentCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity) {
        guard case .comment(let comment) = activity.type else { return }
    }
    
}

class ActivityIssueCommentCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity) {
        guard case .issueComment(let comment) = activity.type else { return }
        
        
    }
}

class ActivityNewIssueCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity) {
        guard case .newIssue(let issue) = activity.type else { return }
        
        
    }
}

class ActivityNewProposalCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity) {
        guard case .newProposal(let proposal) = activity.type else { return }
        
        
    }
}

class ActivityAmendmentDeadlineCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity) {
        guard case .amendmentDeadline(let proposal) = activity.type else { return }
        
        
    }
}

class ActivityVotingDeadlineCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity) {
        guard case .votingDeadline(let proposal) = activity.type else { return }
        
        
    }
}

class ActivityTeamInvitationCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity) {
        guard case .teamInvitation(let member) = activity.type else { return }
        
        
    }
}

class ActivityTeamInvitationApprovalCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity) {
        guard case .teamInvitationApproval(let member) = activity.type else { return }
        
        
    }
}

class ActivityVoteCell: UITableViewCell, ActivityCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet var createdAtLabel: UILabel!
    @IBOutlet var memberCoundLabel: UILabel!
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    func setup(activity: Activity) {
        guard case .vote(let vote) = activity.type else { return }
        
        
    }
}

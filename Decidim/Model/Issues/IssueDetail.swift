//
//  IssueDetail.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

struct IssueDetail {
    let issue: Issue
    let deadline: Date?
    let proposalIds: [Int]
    let commentCount: Int
    let followersCount: Int
    let userIsFollowing: Bool
    
    var hasLocalFollow: Bool = false
    
    public static func from(dict: [String: Any], issue: Issue) -> IssueDetail? {
        guard let commentCount = dict["comments_count"] as? Int else {
            return nil
        }
        
        let followCount = dict["follow_count"] as? Int ?? 0
        let userIsFollowing = dict["is_following"] as? Bool ?? false
        let proposalIds = dict["proposal_ids"] as? [Int] ?? []
        
        var deadline: Date? = nil
        if let deadlineString = dict["deadline"] as? String {
            deadline = Date(timestamp: deadlineString)
        }
        
        return IssueDetail(issue: issue,
                           deadline: deadline,
                           proposalIds: proposalIds,
                           commentCount: commentCount,
                           followersCount: followCount,
                           userIsFollowing: userIsFollowing)
    }
}

extension IssueDetail: Commentable {
    var associatedDataController: CommentDataController {
        return IssueCommentsDataController.shared(issueId: self.issue.id)
    }
}

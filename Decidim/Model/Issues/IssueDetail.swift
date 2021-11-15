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
    let proposalIds: [Int]
    let commentCount: Int
    let followersCount: Int
    
    public static func from(dict: [String: Any]) -> IssueDetail? {
        guard let original = dict["original"] as? [String: Any],
              let issue = Issue.from(dict: original) else {
            return nil
        }
        
        guard let commentCount = dict["comments_count"] as? Int else {
            return nil
        }
        
        let followCount = dict["follow_count"] as? Int ?? 0
        let proposalIds = dict["proposal_ids"] as? [Int] ?? []
        
        return IssueDetail(issue: issue,
                           proposalIds: proposalIds,
                           commentCount: commentCount,
                           followersCount: followCount)
    }
}

extension IssueDetail: Commentable {
    var associatedDataController: CommentDataController {
        return IssueCommentsDataController.shared(issueId: self.issue.id)
    }
}

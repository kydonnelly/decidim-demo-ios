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
    let likeCount: Int
    let commentCount: Int
    
    var hasLocalLike: Bool = false
    
    public static func from(dict: [String: Any], issue: Issue) -> IssueDetail? {
        guard let commentCount = dict["comments_count"] as? Int else {
            return nil
        }
        
        let likeCount = dict["like_count"] as? Int ?? 0
        
        var deadline: Date? = nil
        if let deadlineString = dict["deadline"] as? String {
            deadline = Date(timestamp: deadlineString)
        }
        
        return IssueDetail(issue: issue,
                           deadline: deadline,
                           likeCount: likeCount,
                           commentCount: commentCount)
    }
}

extension IssueDetail: Commentable {
    var associatedDataController: CommentDataController {
        return IssueCommentsDataController.shared(issueId: self.issue.id)
    }
}

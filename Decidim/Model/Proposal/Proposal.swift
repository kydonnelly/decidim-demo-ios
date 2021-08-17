//
//  Proposal.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct Proposal {
    let id: Int
    let issueId: Int
    let authorId: Int
    let title: String
    let body: String
    
    let votingDeadline: Date?
    let amendmentDeadline: Date?
    
    let createdAt: Date
    let updatedAt: Date
    
    let amendmentCount: Int
    let commentCount: Int
    let voteCount: Int
    
    public static func from(dict: [String: Any], id: Int) -> Proposal? {
        guard let userInfo = dict["user"] as? [String: Any] else {
            return nil
        }
        
        guard let issueId = dict["issue_id"] as? Int,
              let authorId = userInfo["id"] as? Int,
              let title = dict["title"] as? String,
              let body = dict["body"] as? String,
              let voteCount = dict["vote_count"] as? Int,
              let commentCount = dict["comments_count"] as? Int,
              let amendmentCount = dict["amendments_count"] as? Int,
              // these fields aren't in the response right now..?
              let createdAt = userInfo["created_at"] as? String,
              let updatedAt = userInfo["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        let votingDeadline = Date(timestamp: dict["voting_deadline"] as? String)
        let amendmentDeadline = Date(timestamp: dict["amendment_deadline"] as? String)
        
        return Proposal(id: id,
                        issueId: issueId,
                        authorId: authorId,
                        title: title,
                        body: body,
                        votingDeadline: votingDeadline,
                        amendmentDeadline: amendmentDeadline,
                        createdAt: createdDate,
                        updatedAt: updatedDate,
                        amendmentCount: amendmentCount,
                        commentCount: commentCount,
                        voteCount: voteCount)
    }
    
    public static func from(dict: [String: Any]) -> Proposal? {
        guard let proposalId = dict["id"] as? Int,
              let issueId = dict["issue_id"] as? Int,
              let authorId = dict["user_id"] as? Int,
              let title = dict["title"] as? String,
              let body = dict["body"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        let votingDeadline = Date(timestamp: dict["voting_deadline"] as? String)
        let amendmentDeadline = Date(timestamp: dict["amendment_deadline"] as? String)
        
        return Proposal(id: proposalId,
                        issueId: issueId,
                        authorId: authorId,
                        title: title,
                        body: body,
                        votingDeadline: votingDeadline,
                        amendmentDeadline: amendmentDeadline,
                        createdAt: createdDate,
                        updatedAt: updatedDate,
                        amendmentCount: 0,
                        commentCount: 0,
                        voteCount: 0)
    }
}

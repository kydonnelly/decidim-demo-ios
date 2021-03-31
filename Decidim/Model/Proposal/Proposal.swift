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
    let authorId: Int
    let title: String
    let body: String
    let iconUrl: String?
    
    let votingDeadline: Date?
    let amendmentDeadline: Date?
    
    let createdAt: Date
    let updatedAt: Date
    
    let commentCount: Int
    let voteCount: Int
    
    public static func from(dict: [String: Any]) -> Proposal? {
        guard let proposalId = dict["id"] as? Int,
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
        
        let thumbnailUrl = dict["icon_url"] as? String
        let votingDeadline = Date(timestamp: dict["voting_deadline"] as? String)
        let amendmentDeadline = Date(timestamp: dict["amendment_deadline"] as? String)
        
        return Proposal(id: proposalId,
                        authorId: authorId,
                        title: title,
                        body: body,
                        iconUrl: thumbnailUrl,
                        votingDeadline: votingDeadline,
                        amendmentDeadline: amendmentDeadline,
                        createdAt: createdDate,
                        updatedAt: updatedDate,
                        commentCount: 0,
                        voteCount: 0)
    }
}

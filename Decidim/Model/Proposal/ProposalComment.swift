//
//  ProposalComment.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct ProposalComment: Comment {
    let commentId: Int
    let authorId: Int
    let proposalId: Int
    let text: String
    let createdAt: Date
    let updatedAt: Date
    
    public static func from(dict: [String: Any]) -> ProposalComment? {
        guard let commentId = dict["id"] as? Int,
              let authorId = dict["user_id"] as? Int,
              let proposalId = dict["proposal_id"] as? Int,
              let body = dict["body"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        return ProposalComment(commentId: commentId,
                               authorId: authorId,
                               proposalId: proposalId,
                               text: body,
                               createdAt: createdDate,
                               updatedAt: updatedDate)
    }
}

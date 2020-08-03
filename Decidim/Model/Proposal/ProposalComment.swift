//
//  ProposalComment.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct ProposalComment {
    let commentId: Int
    let authorId: Int
    let text: String
    let createdAt: Date
    let updatedAt: Date
    
    public static func from(dict: [String: Any]) -> ProposalComment? {
        guard let commentId = dict["id"] as? Int,
              let authorId = dict["user_id"] as? Int,
              let body = dict["body"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let createdDate = formatter.date(from: createdAt),
              let updatedDate = formatter.date(from: updatedAt) else {
            return nil
        }
        
        return ProposalComment(commentId: commentId,
                               authorId: authorId,
                               text: body,
                               createdAt: createdDate,
                               updatedAt: updatedDate)
    }
}

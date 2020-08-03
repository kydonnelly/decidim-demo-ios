//
//  Proposal.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

struct Proposal {
    let id: Int
    let authorId: Int
    let title: String
    let body: String
    let thumbnail: UIImage?
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let createdDate = formatter.date(from: createdAt),
              let updatedDate = formatter.date(from: updatedAt) else {
            return nil
        }
        
        return Proposal(id: proposalId,
                        authorId: authorId,
                        title: title,
                        body: body,
                        thumbnail: nil,
                        createdAt: createdDate,
                        updatedAt: updatedDate,
                        commentCount: 0,
                        voteCount: 0)
    }
}

//
//  Issue.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct Issue {
    let id: Int
    let status: IssueStatus
    let teamId: Int
    let authorId: Int
    let title: String
    let body: String
    let iconUrl: String?
    let deadline: Date?
    let createdAt: Date
    let updatedAt: Date
    let commentCount: Int
    
    public static func from(dict: [String: Any]) -> Issue? {
        guard let issueId = dict["id"] as? Int,
              let teamId = dict["team_id"] as? Int,
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
        
        let iconUrl = dict["icon_url"] as? String
        let issueStatus = dict["status"] as? String ?? ""
        let status = IssueStatus(rawValue: issueStatus) ?? IssueStatus.unknown
        let deadline = Date(timestamp: dict["deadline"] as? String)
        
        return Issue(id: issueId,
                     status: status,
                     teamId: teamId,
                     authorId: authorId,
                     title: title,
                     body: body,
                     iconUrl: iconUrl,
                     deadline: deadline,
                     createdAt: createdDate,
                     updatedAt: updatedDate,
                     commentCount: 0)
    }
}

//
//  TeamAction.swift
//  Decidim
//
//  Created by Kyle Donnelly on 10/20/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct TeamAction {
    let id: Int
    let name: String
    let description: String
    let thumbnailUrl: String?
    let createdAt: Date
    let updatedAt: Date
    let status: TeamActionStatus
    
    public static func from(dict: [String: Any]) -> TeamAction? {
        guard let actionId = dict["id"] as? Int,
              let title = dict["title"] as? String,
              let body = dict["description"] as? String,
              let status = dict["action"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        let actionStatus = TeamActionStatus(rawValue: status) ?? TeamActionStatus.unknown
        
        return TeamAction(id: actionId,
                          name: title,
                          description: body,
                          thumbnailUrl: nil,
                          createdAt: createdDate,
                          updatedAt: updatedDate,
                          status: actionStatus)
    }
}

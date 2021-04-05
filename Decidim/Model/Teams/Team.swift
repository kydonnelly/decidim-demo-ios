//
//  Team.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct Team {
    let id: Int
    let name: String
    let description: String
    let thumbnailUrl: String?
    let createdAt: Date
    let updatedAt: Date
    let memberCount: Int
    let actionCount: Int
    
    public static func from(dict: [String: Any], memberCount: Int = 0, actionCount: Int = 0) -> Team? {
        guard let teamId = dict["id"] as? Int,
              let title = dict["name"] as? String,
              let body = dict["description"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        let thumbnailUrl = dict["icon_url"] as? String
        
        return Team(id: teamId,
                    name: title,
                    description: body,
                    thumbnailUrl: thumbnailUrl,
                    createdAt: createdDate,
                    updatedAt: updatedDate,
                    memberCount: memberCount,
                    actionCount: actionCount)
    }
}

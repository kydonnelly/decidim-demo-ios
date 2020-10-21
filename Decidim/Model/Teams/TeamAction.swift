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
    let status: TeamActionStatus?
    
    public static func from(dict: [String: Any]) -> TeamAction? {
        guard let actionId = dict["id"] as? Int,
              let title = dict["title"] as? String,
              let body = dict["body"] as? String,
              let status = dict["status"] as? String,
              let createdAt = dict["created_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt) else {
            return nil
        }
        
        return TeamAction(id: actionId,
                          name: title,
                          description: body,
                          thumbnailUrl: nil,
                          createdAt: createdDate,
                          status: TeamActionStatus(rawValue: status))
    }
}

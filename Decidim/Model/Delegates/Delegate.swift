//
//  Delegate.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct Delegate {
    let category: String
    let delegationId: Int
    let delegateId: Int
    let userId: Int
    let createdAt: Date
    let updatedAt: Date
    
    public static func from(dict: [String: Any]) -> Delegate? {
        guard let id = dict["id"] as? Int,
              let category = dict["category"] as? String,
              let delegate = dict["delegate"] as? Int,
              let user_id = dict["user_id"] as? Int,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        return Delegate(category: category,
                        delegationId: id,
                        delegateId: delegate,
                        userId: user_id,
                        createdAt: createdDate,
                        updatedAt: updatedDate)
    }
}

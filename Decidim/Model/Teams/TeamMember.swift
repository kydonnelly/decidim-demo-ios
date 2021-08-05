//
//  TeamMember.swift
//  Decidim
//
//  Created by Kyle Donnelly on 12/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct TeamMember {
    let id: Int
    let user_id: Int
    let team_id: Int
    let createdAt: Date
    let updatedAt: Date
    let status: TeamMemberStatus
    let isAdmin: Bool
    
    public static func from(dict: [String: Any]) -> TeamMember? {
        guard let memberId = dict["id"] as? Int,
              let userId = dict["user_id"] as? Int,
              let teamId = dict["team_id"] as? Int,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        // TODO: support team member administration
        var memberStatus = TeamMemberStatus.unknown
        if let s = dict["status"] as? String, let tms = TeamMemberStatus(rawValue: s) {
            memberStatus = tms
        }
        
        // this field is nil when not an admin
        let isAdmin = (dict["admin"] as? Bool) ?? false
        
        return TeamMember(id: memberId,
                          user_id: userId,
                          team_id: teamId,
                          createdAt: createdDate,
                          updatedAt: updatedDate,
                          status: memberStatus,
                          isAdmin: isAdmin)
    }
}

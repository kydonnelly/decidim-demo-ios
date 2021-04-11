//
//  IssueFollower.swift
//  Decidim
//
//  Created by Kyle Donnelly on 4/10/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

struct IssueFollower {
    let followId: Int
    let issueId: Int
    let userId: Int
    
    public static func from(dict: [String: Any]) -> IssueFollower? {
        guard let followId = dict["id"] as? Int,
              let issueId = dict["issue_id"] as? Int,
              let userId = dict["user_id"] as? Int else {
            return nil
        }
        
        return IssueFollower(followId: followId,
                             issueId: issueId,
                             userId: userId)
    }
}

//
//  TeamDetail.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct TeamDetail {
    let team: Team
    let memberList: [TeamMember]
    let actionList: [TeamAction]
    
    public static func from(teamDict: [String: Any],
                            actionDicts: [[String: Any]],
                            memberDicts: [[String: Any]]) -> TeamDetail? {
        guard let team = Team.from(dict: teamDict) else {
            return nil
        }
        
        let members = memberDicts.compactMap({ TeamMember.from(dict: $0) })
        let actions = actionDicts.compactMap({ TeamAction.from(dict: $0) })
        guard members.count == memberDicts.count,
              actions.count == actionDicts.count else {
            return nil
        }
        
        return TeamDetail(team: team,
                          memberList: members,
                          actionList: actions)
    }
}

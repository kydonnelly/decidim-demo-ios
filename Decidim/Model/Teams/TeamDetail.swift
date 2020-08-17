//
//  TeamDetail.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

struct TeamDetail {
    let team: Team
    let memberList: [Int: TeamMemberStatus]
    let actions: [String]
    
    public static func from(dict: [String: Any]) -> TeamDetail? {
        guard let body = dict["body"] as? String else {
            return nil
        }
        
        let components = body.components(separatedBy: "###")
        guard components.count == 5 else {
            return nil
        }
        
        let memberStatuses = components[1].components(separatedBy: "|")
        let members = memberStatuses.reduce(into: [Int: TeamMemberStatus]()) { accumulator, statusString in
            let statusComponents = statusString.components(separatedBy: ":")
            guard let profileId = Int(statusComponents[0]) else {
                return
            }
            guard let rawStatus = Int(statusComponents[1]), let status = TeamMemberStatus(rawValue: rawStatus) else {
                return
            }
            
            accumulator[profileId] = status
        }
        
        let actions = components[2].components(separatedBy: "|")
        let description = components[3]
        
        guard let team = Team.from(dict: dict, memberCount: members.count, description: description) else {
            return nil
        }
        
        return TeamDetail(team: team,
                          memberList: members,
                          actions: actions)
    }
}

extension TeamDetail {
    
    func gradientColors() -> [UIColor] {
        let randomSeed = self.team.id + 1
        let randomRed = CGFloat(randomSeed * 117 % 256) / 256.0
        let randomBlue = CGFloat(randomSeed * 233 % 256) / 256.0
        let randomGreen = CGFloat(randomSeed * 173 % 256) / 256.0
        let startColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        let endColor = UIColor(red: randomRed * 0.5, green: randomGreen * 0.5, blue: randomBlue * 0.5, alpha: 1.0)
        return [startColor, endColor]
    }
    
}

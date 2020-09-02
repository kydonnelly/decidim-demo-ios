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
    let actionList: [String: TeamActionStatus]
    let delegationList: [Int: [Int]]
    
    public static func from(dict: [String: Any]) -> TeamDetail? {
        guard let body = dict["body"] as? String else {
            return nil
        }
        
        let components = body.components(separatedBy: "###")
        guard components.count >= 5 else {
            return nil
        }
        
        let memberStatuses = components[1].components(separatedBy: "|")
        let members = memberStatuses.reduce(into: [Int: TeamMemberStatus]()) { accumulator, statusString in
            guard statusString.count > 0 else {
                return
            }
            
            let statusComponents = statusString.components(separatedBy: ":")
            guard let profileId = Int(statusComponents[0]) else {
                return
            }
            guard let rawStatus = Int(statusComponents[1]), let status = TeamMemberStatus(rawValue: rawStatus) else {
                return
            }
            
            accumulator[profileId] = status
        }
        
        let actionStatuses = components[2].components(separatedBy: "|")
        let actions = actionStatuses.reduce(into: [String: TeamActionStatus]()) { accumulator, statusString in
            guard statusString.count > 0 else {
                return
            }
            
            let statusComponents = statusString.components(separatedBy: ":")
            let description = statusComponents[0]
            
            guard let rawStatus = Int(statusComponents[1]), let status = TeamActionStatus(rawValue: rawStatus) else {
                return
            }
            
            accumulator[description] = status
        }
        
        let description = components[3]
        
        var delegationList: [Int: [Int]] = [:]
        if components.count >= 6 {
            let delegationChains = components[4].components(separatedBy: "|")
            delegationList = delegationChains.reduce(into: [Int: [Int]]()) { accumulator, delegateString in
                guard delegateString.count > 0 else {
                    return
                }
                
                let delegateComponents = delegateString.components(separatedBy: ":")
                guard let profileId = Int(delegateComponents[0]) else {
                    return
                }
                
                let delegates = delegateComponents[1].components(separatedBy: ",").compactMap({ Int($0) })
                accumulator[profileId] = delegates
            }
        }
        
        guard let team = Team.from(dict: dict, memberCount: members.count, description: description) else {
            return nil
        }
        
        return TeamDetail(team: team,
                          memberList: members,
                          actionList: actions,
                          delegationList: delegationList)
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

//
//  TeamMembersDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 12/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class TeamMembersDataController: NetworkDataController {
    
    private var teamId: Int!
    
    static func shared(teamId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(teamId)")
        controller.teamId = teamId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: self.teamId!)
        
        HTTPRequest.shared.get(endpoint: "teams", args: [id, "info"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let memberInfos = response?["members"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let members = memberInfos.compactMap { TeamMember.from(dict: $0) }
            completion(members, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allMembers: [TeamMember] {
        return self.data as? [TeamMember] ?? []
    }
    
    public func banMember(_ userId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "admin", "ban", "\(userId)"]
        
        HTTPRequest.shared.post(endpoint: "teams", args: args, payload: [:]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "success" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            guard let memberInfo = response?["team_user"] as? [String: Any],
                  let member = TeamMember.from(dict: memberInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            // overwrite old data
            self?.data = self?.allMembers.map {
                if $0.user_id == member.user_id {
                    return member
                } else {
                    return $0
                }
            }
            
            completion(nil)
        }
    }
    
    public func unbanMember(_ userId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "admin", "unban", "\(userId)"]
        
        HTTPRequest.shared.post(endpoint: "teams", args: args, payload: [:]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "success" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            guard let memberInfo = response?["team_user"] as? [String: Any],
                  let member = TeamMember.from(dict: memberInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            // overwrite old data
            self?.data = self?.allMembers.map {
                if $0.user_id == member.user_id {
                    return member
                } else {
                    return $0
                }
            }
            
            completion(nil)
        }
    }
    
}

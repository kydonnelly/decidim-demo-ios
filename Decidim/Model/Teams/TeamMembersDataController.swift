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
        
        HTTPRequest.shared.get(endpoint: "teams", args: [id, "users"]) { response, error in
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
    
    public func updateMember(_ userId: Int, status: TeamMemberStatus, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "users", "\(userId)", "add"]
        
        HTTPRequest.shared.put(endpoint: "teams", args: args, payload: [:]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let memberInfos = response?["members"] as? [[String: Any]] else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            // overwrite old data
            self?.data = memberInfos.compactMap { TeamMember.from(dict: $0) }
            completion(nil)
        }
    }
    
    public func removeMember(_ userId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "users", "\(userId)", "remove"]
        
        HTTPRequest.shared.put(endpoint: "teams", args: args, payload: [:]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "found" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            guard let memberInfos = response?["members"] as? [[String: Any]] else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            // overwrite old data
            self?.data = memberInfos.compactMap { TeamMember.from(dict: $0) }
            completion(nil)
        }
    }
    
}

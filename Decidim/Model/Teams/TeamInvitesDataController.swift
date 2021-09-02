//
//  TeamInvitesDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/28/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

class TeamInvitesDataController: NetworkDataController {
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        
        HTTPRequest.shared.get(endpoint: "teams", args: ["list", "invitations"]) { response, error in
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
    
    public var allInvites: [TeamDetail] {
        return self.data as? [TeamDetail] ?? []
    }
    
    public func acceptInvite(_ teamId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: teamId), "membership", "invitation", "accept"]
        
        HTTPRequest.shared.put(endpoint: "teams", args: args, payload: [:]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let userInfo = response?["team_user"] as? [String: Any] else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let member = TeamMember.from(dict: userInfo) {
                self?.data = self?.allInvites.filter { $0.team.id != member.team_id }
                TeamMembersDataController.shared(teamId: member.team_id).invalidate()
            }
            
            completion(nil)
        }
    }
    
    public func rejectInvite(_ teamId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: teamId), "membership", "invitation", "reject"]
        
        HTTPRequest.shared.delete(endpoint: "teams", args: args) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let status = response?["status"] as? String else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            guard status == "success" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            
            self?.data = self?.allInvites.filter { $0.team.id != teamId }
            
            completion(nil)
        }
    }
    
}

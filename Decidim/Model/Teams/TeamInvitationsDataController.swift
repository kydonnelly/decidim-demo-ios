//
//  TeamInvitationsDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/28/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

class TeamInvitationsDataController: NetworkDataController {
    
    private var teamId: Int!
    
    static func shared(teamId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(teamId)")
        controller.teamId = teamId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: self.teamId!)
        
        HTTPRequest.shared.get(endpoint: "teams", args: [id, "admin", "membership", "invitation", "list"]) { response, error in
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
    
    public var allInvitations: [TeamMember] {
        return self.data as? [TeamMember] ?? []
    }
    
    public func inviteMember(_ userId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "admin", "membership", "invitation", "send", "\(userId)"]
        
        HTTPRequest.shared.post(endpoint: "teams", args: args, payload: [:]) { [weak self] response, error in
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
            
            self?.invalidate()
            
            completion(nil)
        }
    }
    
    public func cancelInvitation(_ userId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "admin", "membership", "invitation", "cancel", "\(userId)"]
        
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
            
            self?.data = self?.allInvitations.filter { $0.user_id != userId }
            
            completion(nil)
        }
    }
    
}

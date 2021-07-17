//
//  TeamJoinRequestDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/16/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

class TeamJoinRequestDataController: NetworkDataController {
    
    private var teamId: Int!
    
    static func shared(teamId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(teamId)")
        controller.teamId = teamId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: self.teamId!)
        
        HTTPRequest.shared.get(endpoint: "teams", args: [id, "admin", "membership", "request", "list"]) { response, error in
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
    
    public var allJoinRequests: [TeamMember] {
        return self.data as? [TeamMember] ?? []
    }
    
    public func sendJoinRequest(completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "admin", "membership", "request", "send"]
        
        HTTPRequest.shared.post(endpoint: "teams", args: args, payload: [:]) { [weak self] response, error in
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
    
    public func cancelJoinRequest(completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "admin", "membership", "request", "cancel"]
        
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
            
            if let self = self, let userId = MyProfileController.shared.myProfileId {
                self.data = self.allJoinRequests.filter { $0.user_id != userId }
            }
            
            completion(nil)
        }
    }
    
    public func approveRequest(_ userId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "admin", "membership", "request", "approve", "\(userId)"]
        
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
    
    public func rejectRequest(_ userId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "admin", "membership", "request", "reject", "\(userId)"]
        
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
            
            self?.data = self?.allJoinRequests.filter { $0.user_id != userId }
            
            completion(nil)
        }
    }
    
}


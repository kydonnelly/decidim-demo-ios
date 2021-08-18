//
//  TeamJoinRequestDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/17/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

class TeamJoinRequestDataController: NetworkDataController {
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        HTTPRequest.shared.get(endpoint: "teams", args: ["list", "myRequest"]) { response, error in
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
    
    public func sendJoinRequest(teamId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = ["\(teamId)", "membership", "request", "send"]
        
        HTTPRequest.shared.post(endpoint: "teams", args: args, payload: [:]) { response, error in
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
            
            completion(nil)
        }
    }
    
    public func cancelJoinRequest(teamId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = ["\(teamId)", "membership", "request", "cancel"]
        
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
            
            if let self = self {
                self.data = self.allJoinRequests.filter { $0.team_id != teamId }
            }
            
            completion(nil)
        }
    }
    
}


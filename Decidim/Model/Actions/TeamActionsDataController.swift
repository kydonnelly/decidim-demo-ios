//
//  TeamActionsDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 12/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class TeamActionsDataController: NetworkDataController {
    
    private var teamId: Int!
    private var localActions: [TeamAction] = []
    
    static func shared(teamId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(teamId)")
        controller.teamId = teamId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: self.teamId!)
        
        HTTPRequest.shared.get(endpoint: "teams", args: [id, "actions"]) { [weak self] response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let actionInfos = response?["team_actions"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localActions.removeAll()
            let actions = actionInfos.compactMap { ProposalComment.from(dict: $0) }
            completion(actions, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allActions: [TeamAction] {
        var actions = self.localActions
        if let data = self.data as? [TeamAction] {
            actions.append(contentsOf: data)
        }
        
        return actions
    }
    
    public func addAction(name: String, description: String, status: TeamActionStatus, completion: @escaping (Error?) -> Void) {
        let id = String(describing: self.teamId!)
        let payload: [String: Any] = ["team_action": ["title": name,
                                                      "description": description,
                                                      "type": status.rawValue]]
        
        HTTPRequest.shared.post(endpoint: "teams", args: [id, "actions"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let actionInfo = response?["team_action"] as? [String: Any],
                  let action = TeamAction.from(dict: actionInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localActions.append(action)
            completion(nil)
        }
    }
    
    public func editAction(_ actionId: Int, name: String, description: String, status: TeamActionStatus, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "actions", "\(actionId)"]
        let payload: [String: Any] = ["team_action": ["title": name,
                                                      "description": description,
                                                      "type": status.rawValue]]
        
        HTTPRequest.shared.put(endpoint: "teams", args: args, payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let actionInfo = response?["team_action"] as? [String: Any],
                  let action = TeamAction.from(dict: actionInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let localIndex = self?.localActions.firstIndex(where: { $0.id == actionId }) {
                self?.localActions.remove(at: localIndex)
                self?.localActions.insert(action, at: localIndex)
            }
            
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? TeamAction)?.id == actionId }) {
                self?.data?.remove(at: localIndex)
                self?.data?.insert(action, at: localIndex)
            }
            
            completion(nil)
        }
    }
    
    public func deleteAction(_ actionId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.teamId!), "actions", "\(actionId)"]
        
        HTTPRequest.shared.delete(endpoint: "teams", args: args) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "deleted" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            
            if let localIndex = self?.localActions.firstIndex(where: { $0.id == actionId }) {
                self?.localActions.remove(at: localIndex)
            }
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? TeamAction)?.id == actionId }) {
                self?.data?.remove(at: localIndex)
            }
            
            completion(nil)
        }
    }
    
}

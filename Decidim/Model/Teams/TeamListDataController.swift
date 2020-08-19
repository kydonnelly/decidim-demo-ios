//
//  TeamListDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamListDataController: NetworkDataController {
    
    private var localTeams: [TeamDetail] = []
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        HTTPRequest.shared.get(endpoint: "proposals") { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let proposalInfos = response?["proposals"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let teams = proposalInfos.compactMap { TeamDetail.from(dict: $0) }
            completion(teams, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allTeams: [TeamDetail] {
        var teams = self.localTeams
        if let data = self.data as? [TeamDetail] {
            teams.append(contentsOf: data)
        }
        
        return teams
    }
    
}

extension TeamListDataController {
    
    public func addTeam(title: String, description: String, thumbnail: UIImage?, members: [Int: TeamMemberStatus], completion: @escaping (Error?) -> Void) {
        let membersString = members.map { [String($0), String($1.rawValue)].joined(separator: ":") }.joined(separator: "|")
        let dataString = ["", membersString, "", description, ""].joined(separator: "###")
        let payload: [String: Any] = ["proposal": ["title": title,
                                                   "body": dataString]]
        
        HTTPRequest.shared.post(endpoint: "proposals", payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let proposalInfo = response?["proposal"] as? [String: Any],
                  let team = TeamDetail.from(dict: proposalInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localTeams.append(team)
            completion(nil)
        }
    }
    
    public func editTeam(_ teamId: Int, title: String, description: String, thumbnail: UIImage?, members: [Int: TeamMemberStatus], actions: [String: TeamActionStatus], completion: @escaping (Error?) -> Void) {
        let membersString = members.map { [String($0), String($1.rawValue)].joined(separator: ":") }.joined(separator: "|")
        let actionsString = actions.map { [$0, String($1.rawValue)].joined(separator: ":") }.joined(separator: "|")
        
        let dataString = ["", membersString, actionsString, description, ""].joined(separator: "###")
        let payload: [String: Any] = ["proposal": ["title": title,
                                                   "body": dataString]]
        
        HTTPRequest.shared.put(endpoint: "proposals", args: ["\(teamId)"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let proposalInfo = response?["proposal"] as? [String: Any],
                  let team = TeamDetail.from(dict: proposalInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let localIndex = self?.localTeams.firstIndex(where: { $0.team.id == teamId }) {
                self?.localTeams.remove(at: localIndex)
                self?.localTeams.insert(team, at: localIndex)
            }
            
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? TeamDetail)?.team.id == teamId }) {
                self?.data?.remove(at: localIndex)
                self?.data?.insert(team, at: localIndex)
            }
            
            completion(nil)
        }
    }
    
    public func deleteTeam(_ teamId: Int, completion: @escaping (Error?) -> Void) {
        HTTPRequest.shared.delete(endpoint: "proposals", args: ["\(teamId)"]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "deleted" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            
            if let localIndex = self?.localTeams.firstIndex(where: { $0.team.id == teamId }) {
                self?.localTeams.remove(at: localIndex)
            }
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? TeamDetail)?.team.id == teamId }) {
                self?.data?.remove(at: localIndex)
            }
            
            completion(nil)
        }
    }
    
}


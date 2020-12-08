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
        HTTPRequest.shared.get(endpoint: "teams") { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let teamInfos = response?["teams"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let teams = teamInfos.compactMap { TeamDetail.from(teamDict: $0, actionDicts: [], memberDicts: []) }
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
    
    public func teams(profileId: Int, status: TeamMemberStatus?) -> [TeamDetail] {
        if let targetStatus = status {
            return self.allTeams.filter { $0.memberList.contains { $0.user_id == profileId && $0.status == targetStatus } }
        } else {
            return self.allTeams.filter { !$0.memberList.contains { $0.user_id == profileId } }
        }
    }
    
}

extension TeamListDataController {
    
    public func addTeam(title: String, description: String, thumbnail: UIImage?, members: [Int: TeamMemberStatus], completion: @escaping (Error?) -> Void) {
        let payload: [String: Any] = ["team": ["name": title,
                                               "description": description]]
        
        HTTPRequest.shared.post(endpoint: "teams", payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let teamInfo = response?["team"] as? [String: Any],
                  let memberInfo = response?["members"] as? [[String: Any]],
                  let actionInfo = response?["actions"] as? [[String: Any]],
                  let team = TeamDetail.from(teamDict: teamInfo, actionDicts: actionInfo, memberDicts: memberInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localTeams.append(team)
            completion(nil)
        }
    }
    
    public func editTeam(_ teamId: Int, title: String, description: String, thumbnail: UIImage?, completion: @escaping (Error?) -> Void) {
        let payload: [String: Any] = ["team": ["name": title,
                                               "description": description]]
        
        HTTPRequest.shared.put(endpoint: "teams", args: ["\(teamId)"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let teamInfo = response?["team"] as? [String: Any],
                  let memberInfo = response?["members"] as? [[String: Any]],
                  let actionInfo = response?["actions"] as? [[String: Any]],
                  let team = TeamDetail.from(teamDict: teamInfo, actionDicts: actionInfo, memberDicts: memberInfo) else {
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
        HTTPRequest.shared.delete(endpoint: "teams", args: ["\(teamId)"]) { [weak self] response, error in
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


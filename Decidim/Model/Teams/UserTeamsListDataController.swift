//
//  UserTeamsListDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/16/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class UserTeamsListDataController: NetworkDataController {
    
    private var userId: Int!
    
    static func shared(userId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(userId)")
        controller.userId = userId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: userId!)
        
        HTTPRequest.shared.get(endpoint: "teams", args: ["list", "byAccount", "member", id]) { response, error in
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
        return self.data as? [TeamDetail] ?? []
    }
    
}

extension UserTeamsListDataController {

    public func leaveTeam(_ teamId: Int, completion: @escaping (Error?) -> Void) {
        HTTPRequest.shared.delete(endpoint: "teams", args: ["\(teamId)", "member", "leave"]) { [weak self] response, error in
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

            self?.data = self?.allTeams.filter { $0.team.id != teamId }
            
            completion(nil)
        }
    }

}

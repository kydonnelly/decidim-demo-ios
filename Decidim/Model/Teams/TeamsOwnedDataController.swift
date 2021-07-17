//
//  TeamsOwnedDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/16/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

class TeamsOwnedDataController: NetworkDataController {
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        HTTPRequest.shared.get(endpoint: "teams", args: ["myOwnership"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let teamInfos = response?["user_teams"] as? [[String: Any]] else {
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

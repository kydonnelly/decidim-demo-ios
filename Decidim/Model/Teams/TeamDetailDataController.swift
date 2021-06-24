//
//  TeamDetailDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 12/11/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class TeamDetailDataController: NetworkDataController {
    
    private var teamId: Int!
    
    static func shared(teamId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(teamId)")
        controller.teamId = teamId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let teamId = "\(self.teamId!)"
        
        HTTPRequest.shared.get(endpoint: "teams", args: [teamId, "info"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let teamInfo = response?["team"] as? [String: Any],
                  let memberInfo = response?["members"] as? [[String: Any]],
                  let actionInfo = response?["actions"] as? [[String: Any]],
                  let detail = TeamDetail.from(teamDict: teamInfo, actionDicts: actionInfo, memberDicts: memberInfo) else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            completion([detail], Cursor(next: "", done: true), nil)
        }
    }
    
}

//
//  ProfileInfoDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class ProfileInfoDataController: NetworkDataController {
    
    static func shared() -> Self {
        return super.shared(keyInfo: "All") as! Self
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        HTTPRequest.shared.get(endpoint: "users") { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let profileInfos = response?["users"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let profiles = profileInfos.compactMap { ProfileInfo.from(dict: $0) }
            completion(profiles, Cursor(next: "", done: true), nil)
        }
    }
    
}

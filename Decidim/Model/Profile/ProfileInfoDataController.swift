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
    
    public func editProfile(_ profileId: Int, name: String, thumbnailUrl: String?, completion: @escaping (Error?) -> Void) {
        var issueInfo: [String: Any] = ["name": name]
        if let iconUrl = thumbnailUrl {
            issueInfo["icon_url"] = iconUrl
        }
        
        let payload: [String: Any] = ["user": issueInfo]
        HTTPRequest.shared.put(endpoint: "users", args: ["\(profileId)"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let userInfo = response?["user"] as? [String: Any],
                  let profile = ProfileInfo.from(dict: userInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? ProfileInfo)?.profileId == profile.profileId }) {
                self?.data?.remove(at: localIndex)
                self?.data?.insert(profile, at: localIndex)
            }
            
            MyProfileController.shared.update(username: name) { error in
                completion(error)
            }
        }
    }
    
}

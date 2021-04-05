//
//  ProfileInfo.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct ProfileInfo {
    let profileId: Int
    let handle: String
    let thumbnailUrl: String?
    
    public static func from(dict: [String: Any]) -> ProfileInfo? {
        guard let profileId = dict["id"] as? Int,
              let handle = dict["name"] as? String else {
            return nil
        }
        
        let thumbnailUrl = dict["icon_url"] as? String
        
        return ProfileInfo(profileId: profileId,
                           handle: handle,
                           thumbnailUrl: thumbnailUrl)
    }
}

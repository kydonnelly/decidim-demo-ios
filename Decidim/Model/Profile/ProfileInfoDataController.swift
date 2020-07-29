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
        let testProfiles = [ProfileInfo(profileId: 1, handle: "Kyle", thumbnailUrl: ""),
                            ProfileInfo(profileId: 2, handle: "Tri", thumbnailUrl: ""),
                            ProfileInfo(profileId: 3, handle: "Shawn", thumbnailUrl: ""),
                            ProfileInfo(profileId: 4, handle: "Jay", thumbnailUrl: ""),
                            ProfileInfo(profileId: 5, handle: "Colin", thumbnailUrl: ""),
                            ProfileInfo(profileId: 6, handle: "Hyon", thumbnailUrl: ""),]
        let nextCursor = Cursor(next: "", done: true)
        
        completion(testProfiles, nextCursor, nil)
    }
    
}

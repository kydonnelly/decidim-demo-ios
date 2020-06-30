//
//  ProfileInfoDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class ProfileInfoDataController: NetworkDataController {
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let testProfiles = [ProfileInfo(handle: "Kyle", thumbnailUrl: ""),
                            ProfileInfo(handle: "Tri", thumbnailUrl: ""),
                            ProfileInfo(handle: "Shawn", thumbnailUrl: ""),
                            ProfileInfo(handle: "Hyon", thumbnailUrl: ""),]
        let nextCursor = Cursor(next: "", done: true)
        
        completion(testProfiles, nextCursor, nil)
    }
    
}

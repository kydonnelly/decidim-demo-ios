//
//  ActivityDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

class ActivityDataController: NetworkDataController {
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping NetworkDataController.FetchBlock) {
        HTTPRequest.shared.get(endpoint: "activity", args: ["list"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            
            guard let activityInfos = response?["activities"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let activities = activityInfos.compactMap { Activity.from(dict: $0) }
            completion(activities, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allActivity: [Activity] {
        return self.data as? [Activity] ?? []
    }
    
}

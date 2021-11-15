//
//  IssueDetailDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class IssueDetailDataController: NetworkDataController {
    
    private var backingIssueId: Int!
    
    static func shared(issueId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(issueId)")
        controller.backingIssueId = issueId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let issueId = self.backingIssueId!
        
        HTTPRequest.shared.get(endpoint: "issues", args: ["\(issueId)"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let detailInfo = response?["issue"] as? [String: Any],
                  let detail = IssueDetail.from(dict: detailInfo) else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            completion([detail], Cursor(next: "", done: true), nil)
        }
    }
    
}

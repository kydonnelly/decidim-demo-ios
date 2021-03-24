//
//  IssueDetailDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class IssueDetailDataController: NetworkDataController {
    
    private var backingIssue: Issue!
    
    static func shared(issue: Issue) -> Self {
        let controller = self.shared(keyInfo: "\(issue.id)")
        controller.backingIssue = issue
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let issue = self.backingIssue!
        let issueId = "\(issue.id)"
        
        HTTPRequest.shared.get(endpoint: "issues", args: [issueId]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let detailInfo = response?["issue"] as? [String: Any],
                  let detail = IssueDetail.from(dict: detailInfo, issue: issue) else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            completion([detail], Cursor(next: "", done: true), nil)
        }
    }
    
}

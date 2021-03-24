//
//  PublicIssueDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class PublicIssueDataController: NetworkDataController {
    
    private var localIssues: [Issue] = []
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        HTTPRequest.shared.get(endpoint: "issues") { [weak self] response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let issueInfos = response?["issues"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localIssues.removeAll()
            let issues = issueInfos.compactMap { Issue.from(dict: $0) }
            completion(issues, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allIssues: [Issue] {
        var issues = self.localIssues
        if let data = self.data as? [Issue] {
            issues.append(contentsOf: data)
        }
        
        return issues
    }
    
}

extension PublicIssueDataController {
    
    public func addIssue(title: String, description: String, thumbnail: UIImage?, deadline: Date, completion: @escaping (Error?) -> Void) {
        let payload: [String: Any] = ["issue": ["title": title,
                                                "body": description]]
        
        HTTPRequest.shared.post(endpoint: "issues", payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let issueInfo = response?["issue"] as? [String: Any],
                  let issue = Issue.from(dict: issueInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localIssues.append(issue)
            completion(nil)
        }
    }
    
    public func editIssue(_ issueId: Int, title: String, description: String, thumbnail: UIImage?, deadline: Date?, completion: @escaping (Error?) -> Void) {
        let payload: [String: Any] = ["issue": ["title": title,
                                                "body": description]]
        
        HTTPRequest.shared.put(endpoint: "issues", args: ["\(issueId)"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let issueInfo = response?["issue"] as? [String: Any],
                  let issue = Issue.from(dict: issueInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let localIndex = self?.localIssues.firstIndex(where: { $0.id == issueId }) {
                self?.localIssues.remove(at: localIndex)
                self?.localIssues.insert(issue, at: localIndex)
            }
            
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? Issue)?.id == issueId }) {
                self?.data?.remove(at: localIndex)
                self?.data?.insert(issue, at: localIndex)
            }
            
            completion(nil)
        }
    }
    
    public func deleteIssue(_ issueId: Int, completion: @escaping (Error?) -> Void) {
        HTTPRequest.shared.delete(endpoint: "issues", args: ["\(issueId)"]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "deleted" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            
            if let localIndex = self?.localIssues.firstIndex(where: { $0.id == issueId }) {
                self?.localIssues.remove(at: localIndex)
            }
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? Issue)?.id == issueId }) {
                self?.data?.remove(at: localIndex)
            }
            
            completion(nil)
        }
    }
    
}

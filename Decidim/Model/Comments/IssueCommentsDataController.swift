//
//  IssueCommentsDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class IssueCommentsDataController: NetworkDataController {
    
    private var issueId: Int!
    private var localComments: [IssueComment] = []
    
    static func shared(issueId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(issueId)")
        controller.issueId = issueId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: self.issueId!)
        
        HTTPRequest.shared.get(endpoint: "issues", args: [id, "comments"]) { [weak self] response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let commentInfos = response?["comments"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localComments.removeAll()
            let comments = commentInfos.compactMap { IssueComment.from(dict: $0) }
            completion(comments, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allComments: [IssueComment] {
        var comments = self.localComments
        if let data = self.data as? [IssueComment] {
            comments.append(contentsOf: data)
        }
        
        return comments
    }
    
    public func addComment(_ comment: String, completion: @escaping (Error?) -> Void) {
        let id = String(describing: self.issueId!)
        let payload: [String: Any] = ["comment": ["body": comment]]
        
        HTTPRequest.shared.post(endpoint: "issues", args: [id, "comments"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let commentInfo = response?["comment"] as? [String: Any],
                  let comment = IssueComment.from(dict: commentInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localComments.append(comment)
            completion(nil)
        }
    }
    
    public func editComment(_ commentId: Int, comment: String, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.issueId!), "comments", "\(commentId)"]
        let payload: [String: Any] = ["comment": ["body": comment]]
        
        HTTPRequest.shared.put(endpoint: "issues", args: args, payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let commentInfo = response?["comment"] as? [String: Any],
                  let comment = IssueComment.from(dict: commentInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let localIndex = self?.localComments.firstIndex(where: { $0.commentId == commentId }) {
                self?.localComments.remove(at: localIndex)
                self?.localComments.insert(comment, at: localIndex)
            }
            
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? IssueComment)?.commentId == commentId }) {
                self?.data?.remove(at: localIndex)
                self?.data?.insert(comment, at: localIndex)
            }
            
            completion(nil)
        }
    }
    
    public func deleteComment(_ commentId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.issueId!), "comments", "\(commentId)"]
        
        HTTPRequest.shared.delete(endpoint: "issues", args: args) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "deleted" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            
            if let localIndex = self?.localComments.firstIndex(where: { $0.commentId == commentId }) {
                self?.localComments.remove(at: localIndex)
            }
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? IssueComment)?.commentId == commentId }) {
                self?.data?.remove(at: localIndex)
            }
            
            completion(nil)
        }
    }
    
}

extension IssueCommentsDataController: CommentDataController {
    
    var commentData: [Comment] {
        return self.allComments
    }
    
}

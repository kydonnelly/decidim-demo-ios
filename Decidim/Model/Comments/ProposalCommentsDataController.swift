//
//  ProposalCommentsDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class ProposalCommentsDataController: NetworkDataController {
    
    private var proposalId: Int!
    private var localComments: [ProposalComment] = []
    
    static func shared(proposalId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(proposalId)")
        controller.proposalId = proposalId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: self.proposalId!)
        
        HTTPRequest.shared.get(endpoint: "proposals", args: [id, "comments"]) { [weak self] response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let commentInfos = response?["comments"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localComments.removeAll()
            let comments = commentInfos.compactMap { ProposalComment.from(dict: $0) }
            completion(comments, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allComments: [ProposalComment] {
        var comments = self.localComments
        if let data = self.data as? [ProposalComment] {
            comments.append(contentsOf: data)
        }
        
        return comments
    }
    
    public func addComment(_ comment: String, completion: @escaping (Error?) -> Void) {
        let id = String(describing: self.proposalId!)
        let payload: [String: Any] = ["comment": ["body": comment]]
        
        HTTPRequest.shared.post(endpoint: "proposals", args: [id, "comments"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let commentInfo = response?["comment"] as? [String: Any],
                  let comment = ProposalComment.from(dict: commentInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localComments.append(comment)
            completion(nil)
        }
    }
    
    public func editComment(_ commentId: Int, comment: String, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.proposalId!), "comments", "\(commentId)"]
        let payload: [String: Any] = ["comment": ["body": comment]]
        
        HTTPRequest.shared.put(endpoint: "proposals", args: args, payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let commentInfo = response?["comment"] as? [String: Any],
                  let comment = ProposalComment.from(dict: commentInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let localIndex = self?.localComments.firstIndex(where: { $0.commentId == commentId }) {
                self?.localComments.remove(at: localIndex)
                self?.localComments.insert(comment, at: localIndex)
            }
            
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? ProposalComment)?.commentId == commentId }) {
                self?.data?.remove(at: localIndex)
                self?.data?.insert(comment, at: localIndex)
            }
            
            completion(nil)
        }
    }
    
    public func deleteComment(_ commentId: Int, completion: @escaping (Error?) -> Void) {
        let args: [String] = [String(describing: self.proposalId!), "comments", "\(commentId)"]
        
        HTTPRequest.shared.delete(endpoint: "proposals", args: args) { [weak self] response, error in
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
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? ProposalComment)?.commentId == commentId }) {
                self?.data?.remove(at: localIndex)
            }
            
            completion(nil)
        }
    }
    
}

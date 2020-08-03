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
        
        // test
        HTTPRequest.shared.get(endpoint: "proposals", args: [id, "comments"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let commentInfos = response?["comments"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
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
    
    public func addComment(_ comment: String, authorId: Int, completion: @escaping (Error?) -> Void) {
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
    
}

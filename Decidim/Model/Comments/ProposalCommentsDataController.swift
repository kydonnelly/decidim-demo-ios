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
        let id = String(describing: self.proposalId)
        
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
            
            let comments = commentInfos.compactMap { Proposal.from(dict: $0) }
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
    
    @discardableResult
    public func addComment(_ comment: String, authorId: Int) -> ProposalComment {
        let commentId = max(4, self.data?.compactMap { ($0 as! ProposalComment).commentId }.max() ?? 0 + 1)
        let comment = ProposalComment(commentId: commentId, authorId: authorId, proposalId: self.proposalId, text: comment, createdAt: Date(), updatedAt: Date())
        
        self.localComments.append(comment)
        
        return comment
    }
    
}

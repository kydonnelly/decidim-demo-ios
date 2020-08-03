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
        let randomInt = Int(arc4random())
        
        let testComments = [ProposalComment(commentId: 0, authorId: randomInt * 7 % 6 + 1, text: "This is a comment in support of the proposal because it's a good idea", createdAt: Date(timeIntervalSinceNow: -3600), updatedAt: Date()),
                            ProposalComment(commentId: 1, authorId: randomInt * 3 % 6 + 1, text: "This is a comment opposing the proposal because it's a bad idea", createdAt: Date(timeIntervalSinceNow: -3600 * 2), updatedAt: Date()),
                            ProposalComment(commentId: 2, authorId: randomInt * 11 % 6 + 1, text: "I have an opinion that is unrelated to the proposal but feel the need to share anyway. Have you ever noticed that breakfast tastes better when eaten for dinner? Anyone who isn't on the breakfast-for-dinner bandwagon should try it out. Like if you agree #OmelettesAfterDark", createdAt: Date(timeIntervalSinceNow: -3600 * 25), updatedAt: Date())]
        
        completion(testComments, Cursor(next: "", done: true), nil)
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
        let comment = ProposalComment(commentId: commentId, authorId: authorId, text: comment, createdAt: Date(), updatedAt: Date())
        
        self.localComments.append(comment)
        
        return comment
    }
    
}

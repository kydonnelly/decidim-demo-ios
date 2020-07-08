//
//  ProposalDetailDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class ProposalDetailDataController: NetworkDataController {
    
    private let backingProposal: Proposal
    
    required init(proposal: Proposal, cacheDuration: TimeInterval = 300) {
        self.backingProposal = proposal
        super.init(cacheDuration: cacheDuration)
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let randomInt = Int(arc4random())
        
        let testComments = [ProposalComment(commentId: 0, authorId: randomInt * 7 % 6 + 1, text: "This is a comment in support of the proposal because it's a good idea"),
                            ProposalComment(commentId: 1, authorId: randomInt * 3 % 6 + 1, text: "This is a comment opposing the proposal because it's a bad idea"),
                            ProposalComment(commentId: 2, authorId: randomInt * 11 % 6 + 1, text: "I have an opinion that is unrelated to the proposal but feel the need to share anyway. Have you ever noticed that breakfast tastes better when eaten for dinner? Anyone who isn't on the breakfast-for-dinner bandwagon should try it out. Like if you agree #OmelettesAfterDark")]
        
        let testDetail = ProposalDetail(proposal: self.backingProposal, author: "Test Author \(backingProposal.id + 1)", likeCount: randomInt % 200, deadline: Date(timeIntervalSinceNow: TimeInterval(randomInt % 50000)), amendmentCount: randomInt % 24, comments: testComments)
        
        completion([testDetail], Cursor(next: "", done: true), nil)
    }
    
}

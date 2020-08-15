//
//  ProposalDetailDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class ProposalDetailDataController: NetworkDataController {
    
    private var backingProposal: Proposal!
    
    static func shared(proposal: Proposal) -> Self {
        let controller = self.shared(keyInfo: "\(proposal.id)")
        controller.backingProposal = proposal
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let randomInt = Int(arc4random())
        
        let testDetail = ProposalDetail(proposal: self.backingProposal, authorId: self.backingProposal.authorId, likeCount: randomInt % 200, deadline: Date(timeIntervalSinceNow: TimeInterval(randomInt % 50000)), amendmentCount: randomInt % 24)
        
        completion([testDetail], Cursor(next: "", done: true), nil)
    }
    
}

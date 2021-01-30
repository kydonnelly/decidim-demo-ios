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
        let proposal = self.backingProposal!
        let proposalId = "\(proposal.id)"
        
        HTTPRequest.shared.get(endpoint: "proposals", args: [proposalId]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let detailInfo = response?["proposal"] as? [String: Any],
                  let detail = ProposalDetail.from(dict: detailInfo, proposal: proposal) else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            completion([detail], Cursor(next: "", done: true), nil)
        }
    }
    
}

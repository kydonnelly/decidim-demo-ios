//
//  ProposalDetailDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class ProposalDetailDataController: NetworkDataController {
    
    private var proposalId: Int!
    
    static func shared(proposalId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(proposalId)")
        controller.proposalId = proposalId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let proposalId = self.proposalId!
        
        HTTPRequest.shared.get(endpoint: "proposals", args: ["\(proposalId)"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let detailInfo = response?["proposal"] as? [String: Any],
                  let proposal = Proposal.from(dict: detailInfo, id: proposalId),
                  let detail = ProposalDetail.from(dict: detailInfo, proposal: proposal) else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            completion([detail], Cursor(next: "", done: true), nil)
        }
    }
    
}

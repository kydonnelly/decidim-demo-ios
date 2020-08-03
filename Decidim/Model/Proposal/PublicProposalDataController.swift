//
//  PublicProposalDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/30/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class PublicProposalDataController: NetworkDataController {
    
    private var localProposals: [Proposal] = []
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        // test
        HTTPRequest.shared.get(endpoint: "proposals") { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let proposals = response?["proposals"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let allProposals = proposals.compactMap { Proposal.from(dict: $0) }
            completion(allProposals, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allProposals: [Proposal] {
        var proposals = self.localProposals
        if let data = self.data as? [Proposal] {
            proposals.append(contentsOf: data)
        }
        
        return proposals
    }
    
    @discardableResult
    public func addProposal(title: String, description: String, thumbnail: UIImage?, deadline: Date) -> Proposal {
        let proposalId = max(20, self.data?.compactMap { ($0 as! Proposal).id }.max() ?? 0 + 1)
        let proposal = Proposal(id: proposalId, authorId: 1, title: title, body: description, thumbnail: thumbnail, createdAt: Date(), updatedAt: Date(), commentCount: 0, voteCount: 0)
        
        self.localProposals.append(proposal)
        
        return proposal
    }
    
}

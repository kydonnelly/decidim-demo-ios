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
            guard let proposalInfos = response?["proposals"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let proposals = proposalInfos.compactMap { Proposal.from(dict: $0) }
            completion(proposals, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allProposals: [Proposal] {
        var proposals = self.localProposals
        if let data = self.data as? [Proposal] {
            proposals.append(contentsOf: data)
        }
        
        return proposals
    }
    
    public func addProposal(title: String, description: String, thumbnail: UIImage?, deadline: Date, completion: @escaping (Error?) -> Void) {
        let payload: [String: Any] = ["proposal": ["title": title,
                                                   "body": description]]
        
        HTTPRequest.shared.post(endpoint: "proposals", payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let proposalInfo = response?["proposal"] as? [String: Any],
                  let proposal = Proposal.from(dict: proposalInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localProposals.append(proposal)
            completion(nil)
        }
    }
    
}

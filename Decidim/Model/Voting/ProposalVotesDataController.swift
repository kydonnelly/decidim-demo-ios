//
//  ProposalVotesDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class ProposalVotesDataController: NetworkDataController {
    
    private var proposalId: Int!
    private var localVotes: [ProposalVote] = []
    
    static func shared(proposalId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(proposalId)")
        controller.proposalId = proposalId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: self.proposalId!)
        
        // test
        HTTPRequest.shared.get(endpoint: "proposals", args: [id, "votes"]) { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let voteInfos = response?["votes"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            let votes = voteInfos.compactMap { ProposalVote.from(dict: $0) }
            completion(votes, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allVotes: [ProposalVote] {
        var votes = self.localVotes
        if let data = self.data as? [ProposalVote] {
            votes.append(contentsOf: data)
        }
        
        return votes
    }
    
    public func addVote(_ vote: VoteType, completion: @escaping (Error?) -> Void) {
        let id = String(describing: self.proposalId!)
        let payload: [String: Any] = ["vote": ["value": vote.rawValue]]
        
        HTTPRequest.shared.post(endpoint: "proposals", args: [id, "votes"], payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let voteInfo = response?["vote"] as? [String: Any],
                  let vote = ProposalVote.from(dict: voteInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localVotes.append(vote)
            completion(nil)
        }
    }
    
}

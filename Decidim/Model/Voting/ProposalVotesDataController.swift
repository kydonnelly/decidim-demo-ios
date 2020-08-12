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
    
    public func editVote(_ voteId: Int, voteType: VoteType, completion: @escaping (Error?) -> Void) {
        let args = [String(describing: self.proposalId!), "votes", "\(voteId)"]
        let payload: [String: Any] = ["vote": ["body": voteType.rawValue]]
        
        HTTPRequest.shared.put(endpoint: "proposals", args: args, payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let voteInfo = response?["vote"] as? [String: Any],
                  let vote = ProposalVote.from(dict: voteInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if let localIndex = self?.localVotes.firstIndex(where: { $0.voteId == voteId }) {
                self?.localVotes.remove(at: localIndex)
                self?.localVotes.insert(vote, at: localIndex)
            }
            
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? ProposalVote)?.voteId == voteId }) {
                self?.data?.remove(at: localIndex)
                self?.data?.insert(vote, at: localIndex)
            }
            
            completion(nil)
        }
    }
    
}

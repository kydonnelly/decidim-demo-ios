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
    private var localVote: ProposalVote?
    private var localVoteKey: NSObject?
    
    static func shared(proposalId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(proposalId)")
        controller.proposalId = proposalId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let id = String(describing: self.proposalId!)
        
        let voteKey = NSObject()
        self.localVoteKey = voteKey
        
        HTTPRequest.shared.get(endpoint: "proposals", args: [id, "votes"]) { [weak self] response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let voteInfos = response?["votes"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if self?.localVoteKey == voteKey {
                self?.localVote = nil
            }
            
            let votes = voteInfos.compactMap { ProposalVote.from(dict: $0) }
            completion(votes, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allVotes: [ProposalVote] {
        var votes = [ProposalVote]()
        
        if let data = self.data as? [ProposalVote] {
            votes.append(contentsOf: data)
        }
        
        if let vote = self.localVote {
            if let dataIndex = votes.firstIndex(where: { $0.voteId == vote.voteId }) {
                votes.remove(at: dataIndex)
                votes.insert(vote, at: dataIndex)
            } else {
                votes.insert(vote, at: 0)
            }
        }
        
        return votes
    }
    
    public func addVote(_ vote: VoteType, completion: @escaping (Error?) -> Void) {
        let id = String(describing: self.proposalId!)
        let payload: [String: Any] = ["vote": ["value": vote.rawValue]]
        
        let voteKey = NSObject()
        let optimisticVote = self.optimisticVote(type: vote)
        self.localVote = optimisticVote
        self.localVoteKey = voteKey
        
        HTTPRequest.shared.post(endpoint: "proposals", args: [id, "votes"], payload: payload) { [weak self] response, error in
            let shouldUpdateLocalVote = self?.localVoteKey == voteKey
            if shouldUpdateLocalVote {
                self?.localVote = nil
            }
            
            guard error == nil else {
                completion(error)
                return
            }
            guard let voteInfo = response?["vote"] as? [String: Any],
                  let vote = ProposalVote.from(dict: voteInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if shouldUpdateLocalVote {
                self?.localVote = vote
            }
            
            completion(nil)
        }
    }
    
    public func editVote(_ voteId: Int, voteType: VoteType, completion: @escaping (Error?) -> Void) {
        let args = [String(describing: self.proposalId!), "votes", "\(voteId)"]
        let payload: [String: Any] = ["vote": ["value": voteType.rawValue]]
        
        let voteKey = NSObject()
        let optimisticVote = self.optimisticVote(type: voteType, voteId: voteId)
        self.localVote = optimisticVote
        self.localVoteKey = voteKey
        
        HTTPRequest.shared.put(endpoint: "proposals", args: args, payload: payload) { [weak self] response, error in
            let shouldUpdateLocalVote = self?.localVoteKey == voteKey
            if shouldUpdateLocalVote {
                self?.localVote = nil
            }
            
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let voteInfo = response?["vote"] as? [String: Any],
                  let vote = ProposalVote.from(dict: voteInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            if shouldUpdateLocalVote {
                if let localIndex = self?.data?.firstIndex(where: { ($0 as? ProposalVote)?.voteId == voteId }) {
                    self?.data?.remove(at: localIndex)
                    self?.data?.insert(vote, at: localIndex)
                } else {
                    self?.localVote = vote
                }
            }
            
            completion(nil)
        }
    }
    
}

extension ProposalVotesDataController {
    
    fileprivate func optimisticVote(type: VoteType, voteId: Int = NSNotFound) -> ProposalVote? {
        guard let authorId = MyProfileController.shared.myProfileId else {
            return nil
        }
        
        let date = Date()
        return ProposalVote(voteId: voteId, voterId: authorId, authorId: authorId, proposalId: self.proposalId, voteType: type, createdAt: date, updatedAt: date)
    }
    
}

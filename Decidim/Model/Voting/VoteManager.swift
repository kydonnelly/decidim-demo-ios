//
//  VoteManager.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class VoteManager {
    
    public typealias VoteCompletion = (Bool) -> Void
    
    static let shared = VoteManager()
    
    private var votes: [Int: VoteType] = [:]
    
    public func addVote(proposalId: Int, type: VoteType, completion: VoteCompletion) {
        self.votes[proposalId] = type
        completion(true)
    }
    
    public func getVote(proposalId: Int) -> VoteType? {
        return self.votes[proposalId]
    }
    
}

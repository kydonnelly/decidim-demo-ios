//
//  ProposalVote.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

enum VoteType: String, CaseIterable {
    case yes
    case no
    case abstain
}

struct ProposalVote {
    let voteId: Int
    let voterId: Int
    let authorId: Int
    let proposalId: Int
    let voteType: VoteType
    let createdAt: Date
    let updatedAt: Date
    
    public static func from(dict: [String: Any]) -> ProposalVote? {
        guard let vote = dict["id"] as? Int,
              let voterId = dict["voter_id"] as? Int,
              let authorId = dict["user_id"] as? Int,
              let proposalId = dict["proposal_id"] as? Int,
              let value = dict["value"] as? String,
              let voteType = VoteType(rawValue: value),
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        return ProposalVote(voteId: vote,
                            voterId: voterId,
                            authorId: authorId,
                            proposalId: proposalId,
                            voteType: voteType,
                            createdAt: createdDate,
                            updatedAt: updatedDate)
    }
    
    public var delegateId: Int? {
        if self.voterId != self.authorId {
            return self.voterId
        } else {
            return nil
        }
    }
}

extension VoteType {
    
    var icon: VotionIcon {
        switch self {
        case .yes:
            return .check
        case .no:
            return .close
        case .abstain:
            return .minus_circle
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .yes:
            return UIColor(hexValue: 0x1A6F68)
        case .no:
            return UIColor(hexValue: 0xD5655A)
        case .abstain:
            return UIColor(hexValue: 0xEFB345)
        }
    }
    
    var displayString: String {
        switch self {
        case .yes:
            return "Approve"
        case .no:
            return "Oppose"
        case .abstain:
            return "Abstain"
        }
    }
    
}

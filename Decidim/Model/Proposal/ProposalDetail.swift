//
//  ProposalDetail.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

struct ProposalDetail {
    let proposal: Proposal
    
    let deadline: Date?
    let likeCount: Int
    let voteCount: Int
    let commentCount: Int
    let amendmentCount: Int
    
    var hasLocalLike: Bool = false
    
    public static func from(dict: [String: Any], proposal: Proposal) -> ProposalDetail? {
        guard let voteCount = dict["vote_count"] as? Int,
              let commentCount = dict["comments_count"] as? Int,
              let amendmentCount = dict["amendments_count"] as? Int else {
            return nil
        }
        
        let likeCount = dict["like_count"] as? Int ?? 0
        
        var deadline: Date? = nil
        if let deadlineString = dict["deadline"] as? String {
            deadline = Date(timestamp: deadlineString)
        }
        
        return ProposalDetail(proposal: proposal,
                              deadline: deadline,
                              likeCount: likeCount,
                              voteCount: voteCount,
                              commentCount: commentCount,
                              amendmentCount: amendmentCount)
    }
}

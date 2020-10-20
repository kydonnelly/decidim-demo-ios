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
    
    let deadline: Date
    let likeCount: Int
    let commentCount: Int
    let amendmentCount: Int
    
    var hasLocalLike: Bool = false
    
    public static func from(dict: [String: Any]) -> ProposalDetail? {
        guard let likeCount = dict["like_count"] as? Int,
              let commentCount = dict["comment_count"] as? Int,
              let amendmentCount = dict["amendment_count"] as? Int,
              let deadline = dict["deadline"] as? String else {
            return nil
        }
        
        guard let deadlineDate = Date(timestamp: deadline) else {
            return nil
        }
        
        return ProposalDetail(proposal: Proposal(id: 0, authorId: 0, title: "", body: "", iconUrl: nil, createdAt: Date(), updatedAt: Date(), commentCount: 0, voteCount: 0),
                              deadline: deadlineDate,
                              likeCount: likeCount,
                              commentCount: commentCount,
                              amendmentCount: amendmentCount)
    }
}

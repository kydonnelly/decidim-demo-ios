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
    
    let voteCount: Int
    let commentCount: Int
    let amendmentCount: Int
    
    public static func from(dict: [String: Any], proposal: Proposal) -> ProposalDetail? {
        guard let voteCount = dict["vote_count"] as? Int,
              let commentCount = dict["comments_count"] as? Int,
              let amendmentCount = dict["amendments_count"] as? Int else {
            return nil
        }
        
        return ProposalDetail(proposal: proposal,
                              voteCount: voteCount,
                              commentCount: commentCount,
                              amendmentCount: amendmentCount)
    }
}

extension ProposalDetail: Commentable {
    var associatedDataController: CommentDataController {
        return ProposalCommentsDataController.shared(proposalId: self.proposal.id)
    }
}

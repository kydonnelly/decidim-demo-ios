//
//  ProposalVote.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

enum VoteType {
    case yes
    case no
    case abstain
}

struct ProposalVote {
    let voteId: Int
    let voteType: VoteType
}

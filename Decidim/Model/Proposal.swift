//
//  Proposal.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

struct Proposal {
    let id: Int
    let title: String
    let body: String
    let comments: [ProposalComment]
    let votes: [ProposalVote]
}

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
    
    let authorId: Int
    let likeCount: Int
    let deadline: Date
    let amendmentCount: Int
    
    var hasLocalLike: Bool = false
}

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
    
    let author: String
    let likeCount: Int
    let deadline: Date
    let amendmentCount: Int
    let comments: [ProposalComment]
    
    func gradientColors() -> [UIColor] {
        let randomSeed = self.proposal.id + 1
        let randomRed = CGFloat(randomSeed * 117 % 256) / 256.0
        let randomBlue = CGFloat(randomSeed * 233 % 256) / 256.0
        let randomGreen = CGFloat(randomSeed * 173 % 256) / 256.0
        let startColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        let endColor = UIColor(red: randomRed * 0.5, green: randomGreen * 0.5, blue: randomBlue * 0.5, alpha: 1.0)
        return [startColor, endColor]
    }
}

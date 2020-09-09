//
//  ProposalDetailBodyCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailBodyCell: CustomTableViewCell {
    
    @IBOutlet var bodyLabel: UILabel!
    
    func setup(detail: ProposalDetail, shouldExpand: Bool) {
        self.bodyLabel.text = detail.proposal.body
        self.bodyLabel.numberOfLines = shouldExpand ? 0 : 2
    }
    
}

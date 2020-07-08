//
//  ProposalDetailAmendmentsCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailAmendmentsCell: UITableViewCell {
    
    @IBOutlet var numAmendmentsLabel: UILabel!
    
    func setup(detail: ProposalDetail) {
        self.numAmendmentsLabel.text = "Amendments: \(detail.amendmentCount)"
    }
    
}

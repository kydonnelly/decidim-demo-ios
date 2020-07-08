//
//  ProposalDetailAuthorCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalDetailAuthorCell: UITableViewCell {
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    
    func setup(detail: ProposalDetail) {
        self.handleLabel.text = detail.author
    }
    
}

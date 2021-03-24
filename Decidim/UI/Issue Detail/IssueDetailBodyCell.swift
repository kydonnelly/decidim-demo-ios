//
//  IssueDetailBodyCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueDetailBodyCell: CustomTableViewCell {
    
    @IBOutlet var bodyLabel: UILabel!
    
    func setup(detail: IssueDetail, shouldExpand: Bool) {
        self.bodyLabel.text = detail.issue.body
        self.bodyLabel.numberOfLines = shouldExpand ? 0 : 2
    }
    
}

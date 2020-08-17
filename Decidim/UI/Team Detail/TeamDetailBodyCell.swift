//
//  TeamDetailBodyCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamDetailBodyCell: UITableViewCell {
    
    @IBOutlet var bodyLabel: UILabel!
    
    func setup(detail: TeamDetail, shouldExpand: Bool) {
        self.bodyLabel.text = detail.team.description
        self.bodyLabel.numberOfLines = shouldExpand ? 0 : 2
    }
    
}

//
//  TeamActionListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamActionListCell: CustomTableViewCell {
    
    @IBOutlet var numActionsLabel: UILabel!
    
    public func setup(detail: TeamDetail) {
        self.numActionsLabel.setPluralizableText(count: detail.actionList.count, singular: "ACTION", plural: "ACTIONS")
    }
    
}

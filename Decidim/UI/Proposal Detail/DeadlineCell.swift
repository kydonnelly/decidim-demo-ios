//
//  DeadlineCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/7/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

enum DeadlineType {
    case generic
    case amendment
    case voting
}

class DeadlineCell: CustomTableViewCell {
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    public func setup(type: DeadlineType, deadline: Date?) {
        self.timeLabel.text = self.displayString(deadline: deadline)
        
        switch type {
        case .generic:
            self.descriptionLabel.text = "DEADLINE"
        case .amendment:
            self.descriptionLabel.text = "AMENDMENT DEADLINE"
        case .voting:
            self.descriptionLabel.text = "VOTING DEADLINE"
        }
    }
    
    private func displayString(deadline: Date?) -> String {
        guard let deadline = deadline else {
            return "None"
        }
        guard deadline.isFuture else {
            return "Expired"
        }
        return deadline.asShortStringLeft()
    }
    
}

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
    @IBOutlet var profileListView: ProfileIconListView!
    @IBOutlet var listViewConstraints: [NSLayoutConstraint]!
    
    func setup(detail: ProposalDetail) {
        self.numAmendmentsLabel.text = "Amendments: \(detail.amendmentCount)"
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else { return }
            
            let allProfiles = dc.data as? [ProfileInfo] ?? []
            let amenders = allProfiles.prefix(min(detail.amendmentCount, allProfiles.count))
            self.profileListView.setup(profiles: [ProfileInfo](amenders))
            
            self.listViewConstraints.forEach { $0.isActive = amenders.count > 0 }
        }
    }
    
}

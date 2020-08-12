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
        self.numAmendmentsLabel.text = "Amendments"
        ProposalAmendmentDataController.shared(proposalId: detail.proposal.id).refresh { [weak self] dc in
            let amendments = dc.data as? [ProposalAmendment] ?? []
            self?.numAmendmentsLabel.text = "Amendments: \(amendments.count)"

            ProfileInfoDataController.shared().refresh { [weak self] dc in
                guard let self = self else { return }
                
                let allProfiles = dc.data as? [ProfileInfo] ?? []
                let allAmenders = Set<Int>(amendments.map { $0.authorId })
                let profiles = allProfiles.filter { allAmenders.contains($0.profileId) }
                self.profileListView.setup(profiles: profiles)
                
                self.listViewConstraints.forEach { $0.isActive = allAmenders.count > 0 }
            }
        }
    }
    
}

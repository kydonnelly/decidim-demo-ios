//
//  VotePreferencesDelegateCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VotePreferencesDelegateCell: UITableViewCell {
    
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var profileListView: ProfileIconListView!
    @IBOutlet var listViewConstraints: [NSLayoutConstraint]!
    
    public func setup(category: String, delegates: [Int]) {
        self.categoryLabel.text = category
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else {
                return
            }
            
            let profiles = dc.data as? [ProfileInfo] ?? []
            let filtered = profiles.filter { delegates.contains($0.profileId) }
            self.profileListView.setup(profiles: filtered)
            
            self.listViewConstraints.forEach { $0.isActive = filtered.count > 0 }
        }
    }
    
}

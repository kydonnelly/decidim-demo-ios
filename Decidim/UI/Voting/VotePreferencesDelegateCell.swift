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
    @IBOutlet var iconImageViews: [UIImageView]!
    
    public func setup(category: String, delegates: [Int]) {
        self.categoryLabel.text = category
        
        for imageView in self.iconImageViews {
            imageView.isHidden = true
        }
        
        ProfileInfoDataController.shared().refresh { [weak self] dc in
            guard let self = self else {
                return
            }
            
            guard let infos = dc.data as? [ProfileInfo] else {
                return
            }
            
            let numShown = min(delegates.count, self.iconImageViews.count)
            for i in 0..<numShown {
                self.iconImageViews[i].isHidden = false
                self.iconImageViews[i].image = infos.first { $0.profileId == delegates[i] }?.thumbnail
            }
        }
    }
    
}

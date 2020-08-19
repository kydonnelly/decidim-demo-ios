//
//  TeamListHeaderView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/18/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamListHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet var titleLabel: UILabel!
    
    public func setup(title: String) {
        self.titleLabel.text = title
    }
    
}

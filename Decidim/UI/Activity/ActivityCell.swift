//
//  ActivityCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

protocol ActivityCell: UITableViewCell {
    typealias ProfileBlock = (Int) -> Void
    
    func setup(activity: Activity, profileRedirectBlock: ProfileBlock?)
}

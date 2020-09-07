//
//  ProfileTabSection.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

protocol ProfileTabDataSource: class {
    var profileId: Int? { get }
    
    var sectionOffset: Int { get }
    var loadingCellId: String { get }
    var tableView: UITableView! { get }
    
    var navigationController: UINavigationController? { get }
}

protocol ProfileTabSection: UITableViewDataSource, UITableViewDelegate {
    func setup(dataSource: ProfileTabDataSource)
}

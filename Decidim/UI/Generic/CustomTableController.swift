//
//  CustomTableController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/2/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

protocol CustomTableController: UIViewController {
    var tableView: UITableView! { get }
}

extension CustomTableController {
    
    @discardableResult
    func scrollToTop() -> Bool {
        let top = -1 * self.tableView.adjustedContentInset.top
        if self.tableView.contentOffset.y >= 24 + top {
            self.tableView.setContentOffset(CGPoint(x: 0, y: top), animated: true)
            return true
        } else {
            return false
        }
    }
    
}

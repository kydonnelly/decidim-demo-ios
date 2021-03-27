//
//  HorizontalListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class HorizontalListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -0.5)
    }
    
}

extension HorizontalListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
    }
    
}

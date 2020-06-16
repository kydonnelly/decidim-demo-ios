//
//  ProposalListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalListViewController: UIViewController {
    
    static let ProposalDetailCellID = "ProposalDetailCell"
    
    private var proposals: [Proposal]!
    
    @IBOutlet var tableView: UITableView!
    
    public func setup(proposals: [Proposal]) {
        self.proposals = proposals
        self.tableView.reloadData()
    }
    
}

extension ProposalListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.proposals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.ProposalDetailCellID, for: indexPath)
        return cell
    }
    
}

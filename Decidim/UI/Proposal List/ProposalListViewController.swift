//
//  ProposalListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProposalListViewController: UIViewController, CustomTableController {
    
    static let LoadingCellID = "LoadingCell"
    static let ProposalDetailCellID = "ProposalDetailCell"
    
    typealias ProposalFilter = (Proposal) -> Bool
    
    @IBOutlet var tableView: UITableView!
    
    private var dataController: PublicProposalDataController!
    
    private var filter: ProposalFilter?
    
    public static func create(filter: ProposalFilter? = nil) -> ProposalListViewController {
        let sb = UIStoryboard(name: "ProposalList", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! ProposalListViewController
        vc.setup(filter: filter)
        return vc
    }
    
    private func setup(filter: ProposalFilter?) {
        self.filter = filter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.dataController = PublicProposalDataController.shared()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.dataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    fileprivate func reloadData() {
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.allProposals.count == 0 {
            self.tableView.showNoResults(message: "No ideas to display", icon: .search)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
    fileprivate var allProposals: [Proposal] {
        var allProposals = self.dataController.allProposals
        if let filter = self.filter {
            allProposals = allProposals.filter { filter($0) }
        }
        
        return allProposals
    }
    
}

extension ProposalListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.allProposals.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ProposalDetailCellID, for: indexPath)
            
            if let proposalCell = cell as? ProposalListCell {
                let proposal = self.allProposals[indexPath.row]
                proposalCell.setup(proposal: proposal)
            }
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let proposal = self.allProposals[indexPath.row]
            let vc = ProposalDetailViewController.create(proposal: proposal)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.dataController.page { [weak self] dc in
                self?.reloadData()
            }
        }
    }
    
}

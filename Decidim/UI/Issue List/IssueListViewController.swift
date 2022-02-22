//
//  IssueListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueListViewController: UIViewController, CustomTableController {
    
    static let LoadingCellID = "LoadingCell"
    static let IssueDetailCellID = "IssueDetailCell"
    
    typealias IssueFilter = (Issue) -> Bool
    
    @IBOutlet var tableView: UITableView!
    
    private var dataController: PublicIssueDataController!
    
    private var filter: IssueFilter?
    
    public static func create(filter: IssueFilter? = nil) -> IssueListViewController {
        let sb = UIStoryboard(name: "IssueList", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! IssueListViewController
        vc.setup(filter: filter)
        return vc
    }
    
    private func setup(filter: IssueFilter?) {
        self.filter = filter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.dataController = PublicIssueDataController.shared()
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
        
        if self.dataController.donePaging && self.allIssues.count == 0 {
            self.tableView.showNoResults(message: "No issues to display", icon: .bubbles3)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
    fileprivate var allIssues: [Issue] {
        var allIssues = self.dataController.allIssues
        if let filter = self.filter {
            allIssues = allIssues.filter { filter($0) }
        }
        
        return allIssues
    }
    
}

extension IssueListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.allIssues.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.IssueDetailCellID, for: indexPath)
            
            if let issueCell = cell as? IssueListCell {
                let issue = self.allIssues[indexPath.row]
                issueCell.setup(issue: issue, onSelect: { [weak self] proposalId in
                    let vc = ProposalDetailViewController.create(proposalId: proposalId)
                    self?.navigationController?.pushViewController(vc, animated: true)
                })
            }
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let issue = self.allIssues[indexPath.row]
            let vc = IssueDetailViewController.create(issue: issue)
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

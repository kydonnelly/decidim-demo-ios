//
//  TeamInvitesViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/28/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamInvitesViewController: UIViewController, CustomTableController {
    
    private static let LoadingCellId = "LoadingCell"
    private static let InviteCellId = "InviteCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var invites: [TeamDetail]?
    private var dataController: TeamInvitesDataController!
    
    public static func create() -> UIViewController {
        let sb = UIStoryboard(name: "TeamInvites", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamInvitesViewController
        vc.setup()
        return vc
    }
    
    func setup() {
        self.dataController = TeamInvitesDataController.shared()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataController.refresh { [weak self] dc in
            self?.refreshData()
        }
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.refreshData()
        }
    }
    
    fileprivate func refreshData() {
        self.invites = self.dataController.allInvites
        
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.dataController.allInvites.count == 0 {
            self.tableView.showNoResults(message: "No invites", icon: .users)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
}

extension TeamInvitesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.invites?.count ?? 0
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 76
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InviteCellId, for: indexPath) as! TeamInviteCell
            
            let teamDetail = self.invites![indexPath.row]
            
            cell.setup(detail: teamDetail) { [weak self] accepted in
                guard let self = self else { return }
                if accepted {
                    self.dataController.acceptInvite(teamDetail.team.id) { [weak self] _ in
                        self?.refreshData()
                    }
                } else {
                    self.dataController.rejectInvite(teamDetail.team.id) { [weak self] _ in
                        self?.refreshData()
                    }
                }
            }

            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellId, for: indexPath)
        }
    }
    
}

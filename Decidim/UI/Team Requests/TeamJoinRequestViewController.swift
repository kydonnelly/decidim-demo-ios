//
//  TeamJoinRequestViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/16/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamJoinRequestViewController: UIViewController, CustomTableController {
    
    private static let LoadingCellId = "LoadingCell"
    private static let RequestCellId = "RequestCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var teams: [TeamDetail]?
    private var dataController: TeamJoinRequestDataController!
    private var teamsDataController: TeamListDataController!
    
    public static func create() -> UIViewController {
        let sb = UIStoryboard(name: "TeamJoinRequest", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamJoinRequestViewController
        vc.setup()
        return vc
    }
    
    func setup() {
        self.dataController = TeamJoinRequestDataController.shared()
        self.teamsDataController = TeamListDataController.shared()
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
        self.teamsDataController.refresh { [weak self] dc in
            self?.refreshData()
        }
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.refreshData()
        }
        self.teamsDataController.invalidate()
        self.teamsDataController.refresh { [weak self] dc in
            self?.refreshData()
        }
    }
    
    fileprivate func refreshData() {
        let requests = self.dataController.allJoinRequests
        self.teams = self.teamsDataController.allTeams.filter { detail in
            return requests.contains { detail.team.id == $0.team_id }
        }
        
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.dataController.allJoinRequests.count == 0 {
            self.tableView.showNoResults(message: "No join requests", icon: .users)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
}

extension TeamJoinRequestViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.teams?.count ?? 0
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.RequestCellId, for: indexPath) as! TeamJoinRequestCell
            
            let teamDetail = self.teams![indexPath.row]
            
            cell.setup(team: teamDetail.team) { [weak self] in
                guard let self = self else { return }
                self.dataController.cancelJoinRequest(teamId: teamDetail.team.id) { [weak self] _ in
                    self?.refreshData()
                }
            }

            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellId, for: indexPath)
        }
    }
    
}

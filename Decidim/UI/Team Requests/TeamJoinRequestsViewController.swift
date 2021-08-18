//
//  TeamJoinRequestsViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/16/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamJoinRequestsViewController: UIViewController, CustomTableController {
    
    private static let LoadingCellId = "LoadingCell"
    private static let RequestCellId = "RequestCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var teamDetail: TeamDetail!
    private var joinRequests: [TeamMember]?
    private var dataController: TeamJoinRequestsDataController!
    
    public static func create(detail: TeamDetail) -> UIViewController {
        let sb = UIStoryboard(name: "TeamJoinRequests", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamJoinRequestsViewController
        vc.setup(detail: detail)
        return vc
    }
    
    func setup(detail: TeamDetail) {
        self.teamDetail = detail
        self.dataController = TeamJoinRequestsDataController.shared(teamId: detail.team.id)
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
        self.joinRequests = self.dataController.allJoinRequests
        
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.dataController.allJoinRequests.count == 0 {
            self.tableView.showNoResults(message: "No join requests", icon: .users)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
}

extension TeamJoinRequestsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.joinRequests?.count ?? 0
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
            
            let member = self.joinRequests![indexPath.row]
            
            let profileInfos = ProfileInfoDataController.shared().data as? [ProfileInfo]
            let profileInfo = profileInfos?.first { $0.profileId == member.user_id }
            
            cell.setup(profile: profileInfo) { [weak self] approved in
                guard let self = self else { return }
                if approved {
                    self.dataController.approveRequest(member.user_id) { [weak self] _ in
                        self?.refreshData()
                    }
                } else {
                    self.dataController.rejectRequest(member.user_id) { [weak self] _ in
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

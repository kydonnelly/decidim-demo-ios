//
//  TeamInvitationsViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/28/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamInvitationsViewController: UIViewController, CustomTableController {
    
    private static let LoadingCellId = "LoadingCell"
    private static let InvitationCellId = "InvitationCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var teamDetail: TeamDetail!
    private var invitations: [TeamMember]?
    private var dataController: TeamInvitationsDataController!
    
    public static func create(detail: TeamDetail) -> UIViewController {
        let sb = UIStoryboard(name: "TeamInvitations", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamInvitationsViewController
        vc.setup(detail: detail)
        return vc
    }
    
    func setup(detail: TeamDetail) {
        self.teamDetail = detail
        self.dataController = TeamInvitationsDataController.shared(teamId: detail.team.id)
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
        self.invitations = self.dataController.allInvitations
        
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.dataController.allInvitations.count == 0 {
            self.tableView.showNoResults(message: "No invitations", icon: .users)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
}

extension TeamInvitationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.invitations?.count ?? 0
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InvitationCellId, for: indexPath) as! TeamInvitationCell
            
            let member = self.invitations![indexPath.row]
            
            let profileInfos = ProfileInfoDataController.shared().data as? [ProfileInfo]
            let profileInfo = profileInfos?.first { $0.profileId == member.user_id }
            
            cell.setup(profile: profileInfo) { [weak self] in
                guard let self = self else { return }
                self.dataController.cancelInvitation(member.user_id) { [weak self] _ in
                    self?.refreshData()
                }
            }

            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellId, for: indexPath)
        }
    }
    
}

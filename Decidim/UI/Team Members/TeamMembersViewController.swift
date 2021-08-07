//
//  TeamMembersViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamMembersViewController: UIViewController, CustomTableController {
    
    private static let LoadingCellId = "LoadingCell"
    private static let MemberCellId = "MemberCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var settingsItem: UIBarButtonItem!
    
    private var teamDetail: TeamDetail!
    private var dataController: TeamMembersDataController!
    
    public static func create(detail: TeamDetail) -> TeamMembersViewController {
        let sb = UIStoryboard(name: "TeamMembers", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamMembersViewController
        vc.setup(detail: detail)
        return vc
    }
    
    func setup(detail: TeamDetail) {
        self.teamDetail = detail
        self.dataController = TeamMembersDataController.shared(teamId: detail.team.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.navigationItem.rightBarButtonItem = nil
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
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.dataController.allMembers.count == 0 {
            self.tableView.showNoResults(message: "No group members", icon: .users)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
        
        if let myId = MyProfileController.shared.myProfileId, self.dataController.allMembers.contains(where: { $0.user_id == myId && $0.isAdmin }) {
            self.navigationItem.rightBarButtonItem = self.settingsItem
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
}

extension TeamMembersViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate func members(status: TeamMemberStatus) -> [TeamMember] {
        return self.dataController.allMembers.filter { $0.status == status }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = TeamMemberStatus.allCases.count
        if !self.dataController.donePaging {
            numSections += 1
        }
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == TeamMemberStatus.allCases.count {
            return 1
        } else {
            let status = TeamMemberStatus.allCases[section]
            return self.members(status: status).count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == TeamMemberStatus.allCases.count {
            return 44
        } else {
            return 76
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < TeamMemberStatus.allCases.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.MemberCellId, for: indexPath) as! TeamMemberCell
            
            let status = TeamMemberStatus.allCases[indexPath.section]
            let member = self.members(status: status)[indexPath.row]
            
            var canManage = false
            if let myProfileId = MyProfileController.shared.myProfileId {
                canManage = teamDetail.memberList.contains { $0.user_id == myProfileId && $0.isAdmin }
            }
            
            let profileInfos = ProfileInfoDataController.shared().data as? [ProfileInfo]
            let profileInfo = profileInfos?.first { $0.profileId == member.user_id }
            
            cell.setup(profile: profileInfo, status: status, canManage: canManage) { [weak self] in
                let completion: (Error?) -> Void = { [weak self] _ in
                    guard let self = self else { return }
                    self.refreshData()
                    self.dataController.invalidate()
                    self.dataController.refresh { [weak self] _ in
                        self?.refreshData()
                    }
                }
                
                switch status {
                case .requested:
                    let dataController = TeamJoinRequestDataController.shared(teamId: member.team_id)
                    dataController.approveRequest(member.user_id, completion: completion)
                case .active:
                    let dataController = TeamMembersDataController.shared(teamId: member.team_id)
                    dataController.banMember(member.user_id, completion: completion)
                case .invited:
                    let dataController = TeamInvitationsDataController.shared(teamId: member.team_id)
                    dataController.cancelInvitation(member.user_id, completion: completion)
                case .banned:
                    let dataController = TeamMembersDataController.shared(teamId: member.team_id)
                    dataController.unbanMember(member.user_id, completion: completion)
                case .unknown:
                    completion(nil)
                }
            }

            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section < TeamMemberStatus.allCases.count {
            let status = TeamMemberStatus.allCases[indexPath.section]
            let member = self.members(status: status)[indexPath.row]
            
            let vc = ProfileViewController.create(profileId: member.user_id)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension TeamMembersViewController {
    
    @IBAction func tappedOptionsButton(_ sender: UIBarButtonItem) {
        let detail = self.teamDetail!
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
       
        alert.addAction(UIAlertAction(title: "Invite", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let profileVC = ProfileSearchViewController.create(title: "Invite", selectedProfileId: detail.memberList.first?.user_id) { [weak self] toggleId, selectedId in
                
                let completion: (Error?) -> Void = { [weak self] _ in
                    guard let self = self else { return }
                    self.refreshData()
                    self.dataController.invalidate()
                    self.dataController.refresh { [weak self] _ in
                        self?.refreshData()
                    }
                }
                
                if toggleId == selectedId {
                    TeamInvitationsDataController.shared(teamId: detail.team.id).inviteMember(toggleId, completion: completion)
                } else {
                    TeamInvitationsDataController.shared(teamId: detail.team.id).cancelInvitation(toggleId, completion: completion)
                }
            }
            self.navigationController?.pushViewController(profileVC, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Requests", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let requestsVC = TeamJoinRequestsViewController.create(detail: detail)
            self.navigationController?.pushViewController(requestsVC, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Invitations", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let requestsVC = TeamInvitationsViewController.create(detail: detail)
            self.navigationController?.pushViewController(requestsVC, animated: true)
        }))
         
        if let presenter = alert.popoverPresentationController {
            presenter.barButtonItem = sender
        } else {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak weakAlert = alert] _  in
                weakAlert?.dismiss(animated: true, completion: nil)
            }))
        }

        self.present(alert, animated: true, completion: nil)
    }
    
}

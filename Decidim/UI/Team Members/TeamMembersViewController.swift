//
//  TeamMembersViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamMembersViewController: UIViewController {
    
    private static let LoadingCellId = "LoadingCell"
    private static let MemberCellId = "MemberCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var teamDetail: TeamDetail!
    private var dataController: TeamListDataController!
    
    public static func create(detail: TeamDetail) -> TeamMembersViewController {
        let sb = UIStoryboard(name: "TeamMembers", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamMembersViewController
        vc.setup(detail: detail)
        return vc
    }
    
    func setup(detail: TeamDetail) {
        self.teamDetail = detail
        self.dataController = TeamListDataController.shared()
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
        if let fresh = self.dataController.allTeams.last(where: { $0.team.id == self.teamDetail.team.id }) {
            self.teamDetail = fresh
        }
        
        self.tableView.reloadData()
    }
    
}

extension TeamMembersViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate func members(status: TeamMemberStatus) -> [Int] {
        return self.teamDetail.memberList.compactMap { $1 == status ? $0 : nil }
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
            let memberId = self.members(status: status)[indexPath.row]
            
            var canManage = false
            if let myProfileId = MyProfileController.shared.myProfileId {
                canManage = teamDetail.memberList[myProfileId] == .joined
            }
            
            let profileInfos = ProfileInfoDataController.shared().data as? [ProfileInfo]
            let profileInfo = profileInfos?.first { $0.profileId == memberId }
            
            cell.setup(profile: profileInfo, status: status, canManage: canManage) { [weak self] in
                guard let self = self else { return }
                
                var teamMembers = self.teamDetail.memberList
                switch status {
                case .requested:
                    teamMembers[memberId] = .joined
                case .joined:
                    teamMembers.removeValue(forKey: memberId)
                case .invited:
                    teamMembers.removeValue(forKey: memberId)
                }
                
                self.dataController.editTeam(self.teamDetail.team.id, title: self.teamDetail.team.name, description: self.teamDetail.team.description, thumbnail: self.teamDetail.team.thumbnail, members: teamMembers, actions: self.teamDetail.actionList) { [weak self] _ in
                    self?.refreshData()
                }
            }

            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

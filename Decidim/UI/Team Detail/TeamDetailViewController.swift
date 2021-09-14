//
//  TeamDetailViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamDetailViewController: UIViewController, CustomTableController {
    
    static let LoadingCellID = "LoadingCell"
    
    fileprivate enum StaticCell: String, CaseIterable {
        case body = "BodyCell"
        case title = "TitleCell"
        case `private` = "PrivateCell"
        case members = "MembersCell"
        case issues = "IssuesCell"
        case actions = "ActionsCell"
        
        static func ordered(isPrivate: Bool) -> [StaticCell] {
            if isPrivate {
                return [.title, .body, .private]
            } else {
                return [.title, .body, .members, .issues]
            }
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var editDetailsItem: UIBarButtonItem!
    
    private var teamId: Int!
    private var teamDetail: TeamDetail?
    private var detailDataController: TeamDetailDataController!
    
    fileprivate var isAdmin = false
    fileprivate var isMember = false
    fileprivate var expandBody = false
    
    private var overrideLocalStatus: Bool = false
    private var localStatus: TeamMemberStatus? = nil {
        didSet {
            self.overrideLocalStatus = true
        }
    }
    
    private static func create() -> TeamDetailViewController {
        let sb = UIStoryboard(name: "TeamDetail", bundle: .main)
        return sb.instantiateInitialViewController() as! TeamDetailViewController
    }
    
    public static func create(team: Team) -> TeamDetailViewController {
        let vc = self.create()
        vc.setup(teamId: team.id)
        vc.title = team.name
        return vc
    }
    
    public static func create(teamId: Int) -> TeamDetailViewController {
        let vc = self.create()
        vc.setup(teamId: teamId)
        return vc
    }
    
    private func setup(teamId: Int) {
        self.teamId = teamId
        self.detailDataController = TeamDetailDataController.shared(teamId: teamId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = nil
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.detailDataController.refresh { [weak self] dc in
            self?.refreshData()
        }
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.detailDataController.invalidate()
        self.detailDataController.refresh { [weak self] dc in
            self?.refreshData()
        }
    }
    
    fileprivate func refreshData() {
        self.teamDetail = self.detailDataController.data?.first as? TeamDetail
        
        if let detail = self.teamDetail {
            self.title = detail.team.name
        }
        
        if let memberList = self.teamDetail?.memberList,
           let profileId = MyProfileController.shared.myProfileId,
           let profileMember = memberList.first(where: { $0.user_id == profileId && $0.status == .active })
            {
            self.isAdmin = profileMember.isAdmin
            self.isMember = true
        } else {
            self.isAdmin = false
            self.isMember = false
        }
        
        self.navigationItem.rightBarButtonItem = self.isAdmin ? self.editDetailsItem : nil
        
        self.tableView.reloadData()
    }
    
    fileprivate var currentMemberStatus: TeamMemberStatus? {
        if overrideLocalStatus {
            return self.localStatus
        }
        
        guard let detail = self.teamDetail,
              let profileId = MyProfileController.shared.myProfileId,
              let member = detail.memberList.last(where: { $0.user_id == profileId }) else {
            return nil
        }
        
        return member.status
    }
    
    fileprivate var orderedCells: [StaticCell] {
        if let team = self.teamDetail?.team, team.isPrivate,
           self.currentMemberStatus != .active {
            return StaticCell.ordered(isPrivate: true)
        } else {
            return StaticCell.ordered(isPrivate: false)
        }
    }
    
}

extension TeamDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.detailDataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.teamDetail != nil ? self.orderedCells.count : 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = self.orderedCells[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId.rawValue, for: indexPath)
            
            let detail = self.teamDetail!
            switch cellId {
            case .body:
                (cell as! TeamDetailBodyCell).setup(detail: detail, shouldExpand: self.expandBody)
            case .title:
                (cell as! TeamDetailTitleCell).setup(detail: detail, status: self.currentMemberStatus) { [weak self] status in
                    guard let self = self else { return }
                    
                    let completion: (Error?) -> Void = { [weak self] _ in
                        guard let self = self else { return }
                        self.detailDataController.invalidate()
                        self.detailDataController.refresh { [weak self] _ in
                            self?.overrideLocalStatus = false
                            self?.refreshData()
                        }
                    }
                    
                    switch status {
                    case .none:
                        let dataController = TeamJoinRequestDataController.shared()
                        dataController.sendJoinRequest(teamId: detail.team.id, completion: completion)
                        self.localStatus = .requested
                    case .invited:
                        let dataController = TeamInvitesDataController.shared()
                        dataController.acceptInvite(detail.team.id, completion: completion)
                        self.localStatus = .active
                    case .active:
                        self.leaveOrDeleteTeam(completion: completion)
                    case .requested:
                        let dataController = TeamJoinRequestDataController.shared()
                        dataController.cancelJoinRequest(teamId: detail.team.id, completion: completion)
                        self.localStatus = .none
                    case .banned:
                        completion(nil)
                        self.localStatus = .requested
                    case .unknown:
                        completion(nil)
                        self.localStatus = .requested
                    }
                    
                    self.tableView.reloadData()
                }
            case .private:
                // nothing to set up
                break
            case .members:
                (cell as! TeamMemberListCell).setup(detail: detail, canInvite: self.isMember, inviteBlock: { [weak self] in
                    self?.showInviteScreen()
                }, tappedProfileBlock: { [weak self] profileId in
                    guard let navController = self?.navigationController else { return }
                    let profileVC = ProfileViewController.create(profileId: profileId)
                    navController.pushViewController(profileVC, animated: true)
                })
            case .issues:
                (cell as! TeamIssueListCell).setup(detail: detail, canCreate: self.isMember, createBlock: { [weak self] in
                    self?.showCreateIssueScreen()
                }, tappedIssueBlock: { [weak self] issue in
                    guard let navController = self?.navigationController else { return }
                    let profileVC = IssueDetailViewController.create(issue: issue)
                    navController.pushViewController(profileVC, animated: true)
                })
            case .actions:
                (cell as! TeamActionListCell).setup(detail: detail)
            }
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let detail = self.teamDetail!
            let cellId = self.orderedCells[indexPath.row]
            
            switch cellId {
            case .body:
                self.expandBody = !self.expandBody
                self.tableView.reloadRows(at: [indexPath], with: .none)
            case .members:
                let vc = TeamMembersViewController.create(detail: detail)
                self.navigationController?.pushViewController(vc, animated: true)
            case .issues:
                let vc = IssueListViewController.create { $0.teamId == detail.team.id }
                self.navigationController?.pushViewController(vc, animated: true)
            case .actions:
                let vc = TeamActionsViewController.create(detail: detail)
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.detailDataController.page { [weak self] dc in
                self?.refreshData()
            }
        }
    }
    
}

extension TeamDetailViewController {
    
    @IBAction func tappedOptionsButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
       
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let editVC = EditTeamViewController.create(team: self.teamDetail)
            editVC.modalPresentationStyle = .fullScreen
            self.navigationController?.present(editVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self, let teamId = self.teamDetail?.team.id else {
                return
            }
            
            TeamListDataController.shared().deleteTeam(teamId) { [weak self] error in
                guard error == nil else {
                    return
                }
                
                self?.navigationController?.popViewController(animated: true)
            }
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

extension TeamDetailViewController {
    
    fileprivate func showInviteScreen() {
        let teamId = self.teamId!
        let selectedIds = self.teamDetail?.memberList.filter { $0.status == .invited }.map { $0.user_id } ?? []
        
        let inviteVC = ProfileSearchViewController.create(title: "Invite", selectedProfileIds: selectedIds) { profileId, selectedProfileIds in
            if selectedProfileIds.contains(profileId) {
                TeamInvitationsDataController.shared(teamId: teamId).inviteMember(profileId) { _ in
                    // todo
                }
            } else {
                TeamInvitationsDataController.shared(teamId: teamId).cancelInvitation(profileId) { _ in
                    // todo
                }
            }
        }
        self.navigationController?.pushViewController(inviteVC, animated: true)
    }
    
    fileprivate func showCreateIssueScreen() {
        let createVC = EditIssueViewController.create(teamId: self.teamId)
        createVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(createVC, animated: true, completion: nil)
    }
    
    fileprivate func leaveOrDeleteTeam(completion: @escaping (Error?) -> Void) {
        guard let detail = self.teamDetail,
              let profileId = MyProfileController.shared.myProfileId else {
            return
        }
        
        if self.isAdmin && detail.memberList.filter({ $0.isAdmin }).allSatisfy({ $0.user_id == profileId}) {
            let alert = UIAlertController(title: "Delete Group?", message: "You are the only admin in the group. If you leave the group will be deleted.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak weakAlert = alert] _ in
                weakAlert?.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                // Don't call the original completion
                TeamListDataController.shared().deleteTeam(detail.team.id, completion: { [weak self] error in
                    if error == nil {
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let dataController = UserTeamsListDataController.shared(userId: profileId)
            dataController.leaveTeam(detail.team.id, completion: completion)
            self.localStatus = .none
        }
    }
    
}

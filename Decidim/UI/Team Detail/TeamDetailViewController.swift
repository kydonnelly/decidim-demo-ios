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
        case members = "MembersCell"
        case actions = "ActionsCell"
        
        static func ordered() -> [StaticCell] {
            return [.title, .body, .members]
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var editDetailsItem: UIBarButtonItem!
    
    private var team: Team!
    private var teamDetail: TeamDetail?
    private var detailDataController: TeamDetailDataController!
    
    fileprivate var expandBody = false
    
    public static func create(team: Team) -> TeamDetailViewController {
        let sb = UIStoryboard(name: "TeamDetail", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamDetailViewController
        vc.setup(team: team)
        return vc
    }
    
    private func setup(team: Team) {
        self.team = team
        self.detailDataController = TeamDetailDataController.shared(teamId: team.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.team.name
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
        
        if let memberList = self.teamDetail?.memberList,
           let profileId = MyProfileController.shared.myProfileId,
           memberList.contains(where: { $0.user_id == profileId }) {
            self.navigationItem.rightBarButtonItem = self.editDetailsItem
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.tableView.reloadData()
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
            return self.teamDetail != nil ? StaticCell.ordered().count : 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellId = StaticCell.ordered()[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId.rawValue, for: indexPath)
            
            let detail = self.teamDetail!
            switch cellId {
            case .body:
                (cell as! TeamDetailBodyCell).setup(detail: detail, shouldExpand: self.expandBody)
            case .title:
                (cell as! TeamDetailTitleCell).setup(detail: detail) { [weak self] status in
                    guard let self = self else { return }
                    guard let profileId = MyProfileController.shared.myProfileId else { return }
                    
                    var newStatus: TeamMemberStatus?
                    switch status {
                    case .none:
                        newStatus = .requested
                    case .invited:
                        newStatus = .joined
                    case .joined:
                        newStatus = nil
                    case .requested:
                        return
                    }
                    
                    let dataController = TeamMembersDataController.shared(teamId: detail.team.id)
                    if let newStatus = newStatus {
                        dataController.updateMember(profileId, status: newStatus, completion: { [weak self] _ in
                            self?.refreshData()
                        })
                    } else {
                        dataController.removeMember(profileId) { [weak self] _ in
                            self?.refreshData()
                        }
                    }
                }
            case .members:
                (cell as! TeamMemberListCell).setup(detail: detail, inviteBlock: { [weak self] in
                    self?.showInviteScreen()
                }, tappedProfileBlock: { [weak self] profileId in
                    guard let navController = self?.navigationController else { return }
                    let profileVC = ProfileViewController.create(profileId: profileId)
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
            let cellId = StaticCell.ordered()[indexPath.row]
            
            switch cellId {
            case .body:
                self.expandBody = !self.expandBody
                self.tableView.reloadRows(at: [indexPath], with: .none)
            case .members:
                let vc = TeamMembersViewController.create(detail: detail)
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
        let teamId = self.team.id
        let selectedId = self.teamDetail?.memberList.first?.user_id
        
        let inviteVC = ProfileSearchViewController.create(title: "Invite", selectedProfileId: selectedId) { profileId, selectedProfileId in
            if profileId == selectedProfileId {
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
    
}

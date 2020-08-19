//
//  TeamActionsViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamActionsViewController: UIViewController {
    
    private static let ActionCellId = "ActionCell"
    private static let LoadingCellId = "LoadingCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var teamDetail: TeamDetail!
    private var dataController: TeamListDataController!
    
    public static func create(detail: TeamDetail) -> TeamActionsViewController {
        let sb = UIStoryboard(name: "TeamActions", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamActionsViewController
        vc.setup(detail: detail)
        return vc
    }
    
    func setup(detail: TeamDetail) {
        self.teamDetail = detail
        self.dataController = TeamListDataController.shared()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
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

extension TeamActionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate func actions(status: TeamActionStatus) -> [String] {
        return self.teamDetail.actionList.compactMap { $1 == status ? $0 : nil }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = TeamActionStatus.allCases.count
        if !self.dataController.donePaging {
            numSections += 1
        }
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == TeamActionStatus.allCases.count {
            return 1
        } else {
            let status = TeamActionStatus.allCases[section]
            return self.actions(status: status).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < TeamActionStatus.allCases.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ActionCellId, for: indexPath) as! TeamActionCell
            
            let status = TeamActionStatus.allCases[indexPath.section]
            let description = self.actions(status: status)[indexPath.row]
            
            var canUpdate = false
            if let myProfileId = MyProfileController.shared.myProfileId {
                canUpdate = teamDetail.memberList[myProfileId] == .joined
            }
            
            cell.setup(description: description, status: status, canUpdate: canUpdate) { [weak self] in
                guard let self = self else { return }
                
                var teamActions = self.teamDetail.actionList
                switch status {
                case .done:
                    teamActions.removeValue(forKey: description)
                case .inProgress:
                    teamActions[description] = .done
                case .ongoing:
                    teamActions[description] = .done
                case .pending:
                    teamActions[description] = .inProgress
                case .proposed:
                    teamActions[description] = .pending
                }
                
                self.dataController.editTeam(self.teamDetail.team.id, title: self.teamDetail.team.name, description: self.teamDetail.team.description, thumbnail: self.teamDetail.team.thumbnail, members: self.teamDetail.memberList, actions: teamActions) { [weak self] _ in
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
        
        if indexPath.section < TeamActionStatus.allCases.count {
            var canUpdate = false
            if let myProfileId = MyProfileController.shared.myProfileId {
                canUpdate = teamDetail.memberList[myProfileId] == .joined
            }
            
            if canUpdate {
                let status = TeamActionStatus.allCases[indexPath.section]
                let description = self.actions(status: status)[indexPath.row]
                
                let createVC = EditActionViewController.create(detail: self.teamDetail, action: description)
                createVC.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(createVC, animated: true, completion: nil)
            }
        }
    }
    
}

extension TeamActionsViewController {
    
    @IBAction func tappedCreateButton(_ sender: UIBarButtonItem) {
        let createVC = EditActionViewController.create(detail: self.teamDetail)
        createVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(createVC, animated: true, completion: nil)
    }
    
}

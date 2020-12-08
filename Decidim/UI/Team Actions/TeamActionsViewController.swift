//
//  TeamActionsViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamActionsViewController: UIViewController, CustomTableController {
    
    private static let ActionCellId = "ActionCell"
    private static let LoadingCellId = "LoadingCell"
    private static let SectionHeaderID = "SectionHeader"
    
    fileprivate enum Sections: CaseIterable {
        case done
        case inProgress
        case ongoing
        case pending
        case proposed
        
        var asActionStatus: TeamActionStatus {
            switch self {
            case .done: return .done
            case .inProgress: return .inProgress
            case .ongoing: return .ongoing
            case .pending: return .pending
            case .proposed: return .proposed
            }
        }
        
        var title: String {
            switch self {
            case .done: return "Done"
            case .inProgress: return "In Progress"
            case .ongoing: return "Ongoing"
            case .pending: return "Pending Approval"
            case .proposed: return "Proposed"
            }
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    private var teamDetail: TeamDetail!
    private var dataController: TeamActionsDataController!
    
    public static func create(detail: TeamDetail) -> TeamActionsViewController {
        let sb = UIStoryboard(name: "TeamActions", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamActionsViewController
        vc.setup(detail: detail)
        return vc
    }
    
    func setup(detail: TeamDetail) {
        self.teamDetail = detail
        self.dataController = TeamActionsDataController.shared(teamId: detail.team.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(UINib(nibName: "TeamListHeaderView", bundle: .main),
                                forHeaderFooterViewReuseIdentifier: Self.SectionHeaderID)
        
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
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.dataController.allActions.count == 0 {
            self.tableView.showNoResults(message: "No actions")
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
}

extension TeamActionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    fileprivate func actions(section: Sections) -> [TeamAction] {
        let actionStatus = section.asActionStatus
        return self.dataController.allActions.filter { $0.status == actionStatus }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = Sections.allCases.count
        if !self.dataController.donePaging {
            numSections += 1
        }
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Sections.allCases.count {
            return 1
        } else {
            let section = Sections.allCases[section]
            return self.actions(section: section).count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < Sections.allCases.count else {
            return 0
        }
        
        let section = Sections.allCases[section]
        guard self.actions(section: section).count > 0 else {
            return 0
        }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < Sections.allCases.count else {
            return nil
        }
        
        let section = Sections.allCases[section]
        guard self.actions(section: section).count > 0 else {
            return nil
        }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Self.SectionHeaderID) as! TeamListHeaderView
        header.setup(title: section.title)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < Sections.allCases.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ActionCellId, for: indexPath) as! TeamActionCell
            
            let section = Sections.allCases[indexPath.section]
            let action = self.actions(section: section)[indexPath.row]
            
            var canUpdate = false
            if let myProfileId = MyProfileController.shared.myProfileId {
                canUpdate = self.teamDetail.memberList[myProfileId] == .joined
            }
            
            cell.setup(description: action.description, status: section.asActionStatus, canUpdate: canUpdate) { [weak self] in
                guard let self = self else { return }
                
                var newStatus: TeamActionStatus
                switch section {
                case .done:
                    newStatus = .archived
                case .inProgress:
                    newStatus = .done
                case .ongoing:
                    newStatus = .done
                case .pending:
                    newStatus = .inProgress
                case .proposed:
                    newStatus = .pending
                }
                
                self.dataController.editAction(action.id, name: action.name, description: action.description, status: newStatus) { [weak self] _ in
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
        
        if indexPath.section < Sections.allCases.count {
            var canUpdate = false
            if let myProfileId = MyProfileController.shared.myProfileId {
                canUpdate = self.teamDetail.memberList[myProfileId] == .joined
            }
            
            if canUpdate {
                let section = Sections.allCases[indexPath.section]
                let action = self.actions(section: section)[indexPath.row]
                
                let createVC = EditActionViewController.create(teamId: self.teamDetail.team.id, action: action)
                createVC.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(createVC, animated: true, completion: nil)
            }
        }
    }
    
}

extension TeamActionsViewController {
    
    @IBAction func tappedCreateButton(_ sender: UIBarButtonItem) {
        let createVC = EditActionViewController.create(teamId: self.teamDetail.team.id)
        createVC.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(createVC, animated: true, completion: nil)
    }
    
}

//
//  ProfileTeamsTabSection.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileTeamsTabSection: NSObject, ProfileTabSection {
    
    static let teamsCellId = "TeamListCell"
    static let sectionHeaderId = "TeamsSectionHeader"
    
    fileprivate enum TableSection: Int, CaseIterable {
        case owned
        case joined
        
        var title: String {
            switch self {
            case .owned: return "Owned"
            case .joined: return "Joined"
            }
        }
    }
    
    private weak var dataSource: ProfileTabDataSource?
    private var teamsDataController: UserTeamsListDataController!
    private var ownedDataController: TeamsOwnedDataController!
    
    func setup(dataSource: ProfileTabDataSource) {
        self.dataSource = dataSource
        
        dataSource.tableView.register(UINib(nibName: "TeamListHeaderView", bundle: .main),
                                      forHeaderFooterViewReuseIdentifier: Self.sectionHeaderId)
        
        guard let profileId = dataSource.profileId else { return }
        self.teamsDataController = UserTeamsListDataController.shared(userId: profileId)
        self.ownedDataController = TeamsOwnedDataController.shared(userId: profileId)
        
        self.teamsDataController.refresh { [weak self] dc in
            self?.reloadData()
        }
        self.ownedDataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    func reloadData() {
        guard let dataSource = self.dataSource else {
            return
        }
        
        dataSource.tableView.reloadData()
        
        if self.teamsDataController.donePaging && self.teamsDataController.allTeams.count == 0 {
            dataSource.tableView.showNoResults(message: "No groups to display", icon: .users, below: dataSource.sectionOffset)
        } else {
            dataSource.tableView.hideNoResultsIfNeeded()
        }
    }
    
    fileprivate func teams(section: TableSection) -> [TeamDetail] {
        switch section {
        case .owned:
            return self.ownedDataController.allTeams
        case .joined:
            return self.teamsDataController.allTeams
        }
    }
    
}

extension ProfileTeamsTabSection: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = TableSection.allCases.count
        if !self.teamsDataController.donePaging {
            numSections += 1
        }
        return numSections
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            return 0
        }
        
        guard let tableSection = TableSection(rawValue: section - sectionOffset) else {
            return 0
        }
        
        guard TableSection.allCases.filter({ self.teams(section: $0).count > 0 }).count > 1 else {
            return 0
        }
        
        guard self.teams(section: tableSection).count > 0 else {
            return 0
        }
        
        return 48
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            return nil
        }
        
        guard let tableSection = TableSection(rawValue: section - sectionOffset) else {
            return nil
        }
        
        guard TableSection.allCases.filter({ self.teams(section: $0).count > 0 }).count > 1 else {
            return nil
        }
        
        guard self.teams(section: tableSection).count > 0 else {
            return nil
        }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Self.sectionHeaderId) as! TeamListHeaderView
        header.setup(title: tableSection.title)
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            return 0
        }
        
        if let tableSection = TableSection(rawValue: section - sectionOffset) {
            return self.teams(section: tableSection).count
        } else {
            // loading section
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            preconditionFailure("Missing section offset")
        }
        
        if let tableSection = TableSection(rawValue: indexPath.section - sectionOffset) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.teamsCellId, for: indexPath) as! TeamListCell
            
            let team = self.teams(section: tableSection)[indexPath.row].team
            cell.setup(team: team)

            return cell
        } else {
            guard let dataSource = self.dataSource else {
                return UITableViewCell()
            }
            
            return tableView.dequeueReusableCell(withIdentifier: dataSource.loadingCellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            return
        }
        
        if let tableSection = TableSection(rawValue: indexPath.section - sectionOffset) {
            let teamDetail = self.teams(section: tableSection)[indexPath.row]
            let vc = TeamDetailViewController.create(team: teamDetail.team)
            self.dataSource?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            return
        }
        
        if indexPath.section == sectionOffset + TableSection.allCases.count {
            self.teamsDataController.page { [weak self] dc in
                self?.reloadData()
            }
        }
    }
    
}

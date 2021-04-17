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
    
    private weak var dataSource: ProfileTabDataSource?
    private var dataController: TeamListDataController!
    
    func setup(dataSource: ProfileTabDataSource) {
        self.dataSource = dataSource
        
        self.dataController = TeamListDataController.shared()
        self.dataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    func reloadData() {
        guard let dataSource = self.dataSource else {
            return
        }
        
        dataSource.tableView.reloadData()
        
        if self.dataController.donePaging && self.allTeams().count == 0 {
            dataSource.tableView.showNoResults(message: "No groups to display", icon: .users, below: dataSource.sectionOffset)
        } else {
            dataSource.tableView.hideNoResultsIfNeeded()
        }
    }
    
    fileprivate func allTeams() -> [Team] {
        guard let profileId = self.dataSource?.profileId else {
            return []
        }
        
        return self.dataController.teams(profileId: profileId, status: .joined)
    }
    
}

extension ProfileTeamsTabSection: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            return 0
        }
        
        if section == sectionOffset {
            return self.allTeams().count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            preconditionFailure("Missing section offset")
        }
        
        if indexPath.section == sectionOffset {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.teamsCellId, for: indexPath) as! TeamListCell
            
            let team = self.allTeams()[indexPath.row]
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
        
        if indexPath.section == sectionOffset {
            let team = self.allTeams()[indexPath.row]
            let vc = TeamDetailViewController.create(team: team)
            self.dataSource?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            return
        }
        
        if indexPath.section == sectionOffset + 1 {
            self.dataController.page { [weak self] dc in
                self?.reloadData()
            }
        }
    }
    
}

//
//  ProfileProposalsTabSection.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileProposalsTabSection: NSObject, ProfileTabSection {
    
    static let proposalsCellId = "ProposalListCell"
    
    private weak var dataSource: ProfileTabDataSource?
    private var dataController: PublicProposalDataController!
    
    func setup(dataSource: ProfileTabDataSource) {
        self.dataSource = dataSource
        
        self.dataController = PublicProposalDataController.shared()
        self.dataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    func reloadData() {
        guard let dataSource = self.dataSource else {
            return
        }
        
        dataSource.tableView.reloadData()
        
        if self.dataController.donePaging && self.allProposals.count == 0 {
            dataSource.tableView.showNoResults(message: "No proposals", below: dataSource.sectionOffset)
        } else {
            dataSource.tableView.hideNoResultsIfNeeded()
        }
    }
    
    fileprivate var allProposals: [Proposal] {
        let proposals = self.dataController.allProposals
        return proposals.filter { $0.authorId == self.dataSource?.profileId }
    }
    
}

extension ProfileProposalsTabSection: UITableViewDataSource, UITableViewDelegate {
    
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
            return self.allProposals.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            preconditionFailure("Missing section offset")
        }
        
        if indexPath.section == sectionOffset {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.proposalsCellId, for: indexPath)
            
            if let proposalCell = cell as? ProposalListCell {
                let proposal = self.allProposals[indexPath.row]
                proposalCell.setup(proposal: proposal)
            }
            
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
            let proposal = self.allProposals[indexPath.row]
            let vc = ProposalDetailViewController.create(proposal: proposal)
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

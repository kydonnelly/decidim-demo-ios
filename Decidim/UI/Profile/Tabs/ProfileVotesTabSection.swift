//
//  ProfileVotesTabSection.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileVotesTabSection: NSObject, ProfileTabSection {
    
    static let voteHistoryCellId = "VoteHistoryCell"
    
    private weak var dataSource: ProfileTabDataSource?
    
    private var dataController: PublicProposalDataController!
    private var proposalVotes: [(Proposal, ProposalVote)] = []
    private var isRefreshing: Bool = false
    
    func setup(dataSource: ProfileTabDataSource) {
        self.dataSource = dataSource
        
        self.dataController = PublicProposalDataController.shared()
        self.dataController.refresh { [weak self] dc in
            self?.refreshVotes()
        }
    }
    
    private func refreshVotes() {
        guard !self.isRefreshing else { return }
        guard let profileId = self.dataSource?.profileId else { return }
        
        self.isRefreshing = true
        self.proposalVotes.removeAll()
        
        let allProposals = self.dataController.allProposals
        var count = allProposals.count
        
        for proposal in allProposals {
            ProposalVotesDataController.shared(proposalId: proposal.id).refresh { [weak self] dc in
                count -= 1
                
                guard let self = self, let dc = dc as? ProposalVotesDataController else {
                    return
                }
                if let vote = dc.allVotes.last(where: { $0.authorId == profileId }) {
                    self.proposalVotes.append((proposal, vote))
                }
                
                if count == 0 {
                    self.isRefreshing = false
                    self.dataSource?.tableView.reloadData()
                }
            }
        }
    }
    
}

extension ProfileVotesTabSection: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !self.dataController.donePaging || self.isRefreshing {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            return 0
        }
        
        if section == sectionOffset {
            return self.proposalVotes.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionOffset = self.dataSource?.sectionOffset else {
            preconditionFailure("Missing section offset")
        }
        
        if indexPath.section == sectionOffset {
            let (proposal, vote) = self.proposalVotes[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.voteHistoryCellId, for: indexPath) as! ProposalVoteCell
            cell.setup(proposal: proposal, myVote: vote.voteType)
            
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
            let (proposal, _) = self.proposalVotes[indexPath.row]
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
                self?.refreshVotes()
            }
        }
    }
    
}

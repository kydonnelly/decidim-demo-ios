//
//  IssueDetailProposalListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/24/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueDetailProposalListViewController: HorizontalListViewController {
    
    typealias CreateBlock = () -> Void
    typealias ExpandBlock = (Proposal) -> Void
    
    static let createCellId = "CreateCell"
    static let proposalCellId = "ProposalCell"
    
    private var createBlock: CreateBlock?
    private var expandBlock: ExpandBlock?
    
    private var issueDetail: IssueDetail!
    
    private var proposals: [Proposal] = []
    private var dataController: PublicProposalDataController!
    
    public static func create() -> IssueDetailProposalListViewController {
        let sb = UIStoryboard(name: "IssueDetailProposalList", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! IssueDetailProposalListViewController
        return vc
    }
    
    public func setup(detail: IssueDetail, onCreate: CreateBlock?, onExpand: ExpandBlock?) {
        self.issueDetail = detail
        
        self.createBlock = onCreate
        self.expandBlock = onExpand
        
        self.dataController = PublicProposalDataController.shared()
        self.dataController.refresh { [weak self] dc in
            guard let self = self else { return }
            
            self.proposals = self.dataController.allProposals.filter {
                detail.proposalIds.contains($0.id)
            }
            
            self.proposals.forEach {
                ProposalVotesDataController.shared(proposalId: $0.id).refresh { [weak self] _ in
                    self?.tableView.reloadData()
                }
            }
            
            self.tableView.reloadData()
        }
        
        self.tableView.reloadData()
    }
    
}

extension IssueDetailProposalListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.proposals.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 198
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.proposalCellId, for: indexPath) as! IssueDetailProposalCell
            
            let proposal = self.proposals[indexPath.row]
            let dataController = ProposalVotesDataController.shared(proposalId: proposal.id)
            let allVotes = dataController.allVotes
            let myVote = dataController.allVotes.last { $0.authorId == MyProfileController.shared.myProfileId }
            
            cell.setup(proposal: proposal, votes: allVotes, myVote: myVote?.voteType) { [weak self] _ in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                for voteType in VoteType.allCases {
                    alert.addAction(UIAlertAction(title: voteType.displayString, style: .default, handler: { [weak self] _ in
                        self?.updateVote(proposal: proposal, existingVote: myVote, voteType: voteType)
                    }))
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self?.present(alert, animated: true, completion: nil)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.createCellId, for: indexPath) as! IssueDetailCreateProposalCell
            return cell
        }
    }
    
}

extension IssueDetailProposalListViewController {
    
    fileprivate func updateVote(proposal: Proposal, existingVote: ProposalVote?, voteType: VoteType) {
        let votesDC = ProposalVotesDataController.shared(proposalId: proposal.id)
        
        if let existingId = existingVote?.voteId {
            votesDC.editVote(existingId, voteType: voteType) { [weak self] _ in
                self?.tableView.reloadData()
            }
        } else {
            votesDC.addVote(voteType) { [weak self] _ in
                self?.tableView.reloadData()
            }
        }
    }
    
}

/// UITableViewDelegate

extension IssueDetailProposalListViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let proposal = self.proposals[indexPath.row]
            self.expandBlock?(proposal)
        } else {
            self.createBlock?()
        }
    }
    
}

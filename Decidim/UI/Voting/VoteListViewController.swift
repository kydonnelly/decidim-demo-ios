//
//  VoteListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VoteListViewController: UIViewController {
    
    static let proposalVoteCellId = "ProposalVoteCell"
    static let loadingCellId = "LoadingCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var dataController: PublicProposalDataController!
    private var proposals: [Proposal] = []
    
    public static func create() -> VoteListViewController {
        let sb = UIStoryboard(name: "VoteList", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! VoteListViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Vote History"
        
        self.dataController = PublicProposalDataController.shared()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataController.refresh { [weak self] _ in
            self?.refresh()
        }
    }
    
    private func refresh() {
        self.proposals.removeAll()
        let allProposals = self.dataController.allProposals
        var count = allProposals.count
        
        for proposal in allProposals {
            ProposalVotesDataController.shared(proposalId: proposal.id).refresh { [weak self] dc in
                count -= 1
                
                guard let dc = dc as? ProposalVotesDataController else {
                    return
                }
                if (dc.allVotes.map { $0.authorId }.contains(6)) {
                    self?.proposals.append(proposal)
                }
                
                if count == 0 {
                    self?.tableView?.reloadData()
                }
            }
        }
    }
    
}

extension VoteListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.proposals.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 96
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let proposal = self.proposals[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.proposalVoteCellId, for: indexPath) as! ProposalVoteCell
            cell.setup(proposal: proposal)
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.loadingCellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let proposal = self.proposals[indexPath.row]
            let vc = ProposalDetailViewController.create(proposal: proposal)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.dataController.page { [weak self] dc in
                self?.refresh()
            }
        }
    }
    
}

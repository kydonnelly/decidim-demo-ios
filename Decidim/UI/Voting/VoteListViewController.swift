//
//  VoteListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VoteListViewController: UIViewController, CustomTableController {
    
    static let proposalVoteCellId = "ProposalVoteCell"
    static let loadingCellId = "LoadingCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var dataController: PublicProposalDataController!
    private var proposalVotes: [(Proposal, ProposalVote)] = []
    private var isRefreshing: Bool = false
    
    public static func create() -> VoteListViewController {
        let sb = UIStoryboard(name: "VoteList", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! VoteListViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Vote History"
        
        self.dataController = PublicProposalDataController.shared()
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
        
    }
    
    private func refresh() {
        self.dataController.refresh { [weak self] _ in
            self?.refreshVotes()
        }
    }
    
    private func refreshVotes() {
        guard !self.isRefreshing else { return }
        
        self.isRefreshing = true
        self.proposalVotes.removeAll()
        
        let allProposals = self.dataController.allProposals
        var count = allProposals.count
        
        let profileId = MyProfileController.shared.myProfileId
        
        for proposal in allProposals {
            ProposalVotesDataController.shared(proposalId: proposal.id).refresh { [weak self] dc in
                count -= 1
                
                guard let dc = dc as? ProposalVotesDataController else {
                    return
                }
                if let vote = dc.allVotes.last(where: { $0.authorId == profileId }) {
                    self?.proposalVotes.append((proposal, vote))
                }
                
                if count == 0 {
                    self?.isRefreshing = false
                    self?.tableView?.reloadData()
                }
            }
        }
    }
    
}

extension VoteListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !self.dataController.donePaging || self.isRefreshing {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.proposalVotes.count
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
            let (proposal, vote) = self.proposalVotes[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.proposalVoteCellId, for: indexPath) as! ProposalVoteCell
            cell.setup(proposal: proposal, myVote: vote.voteType)
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.loadingCellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let (proposal, _) = self.proposalVotes[indexPath.row]
            let vc = ProposalDetailViewController.create(proposal: proposal)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.dataController.page { [weak self] dc in
                self?.refreshVotes()
            }
        }
    }
    
}

extension VoteListViewController {
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.refresh()
    }
    
}

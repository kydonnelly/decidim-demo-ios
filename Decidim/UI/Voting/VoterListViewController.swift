//
//  VoterListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/2/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VoterListViewController: UIViewController, CustomTableController {
    
    @IBOutlet var tableView: UITableView!
    
    private var proposal: Proposal!
    private var dataController: ProposalVotesDataController!
    
    private static let ResultCellId = "VoterCell"
    private static let LoadingCellId = "LoadingCell"
    
    static func create(proposal: Proposal) -> UIViewController {
        let sb = UIStoryboard(name: "VoterList", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! UINavigationController
        let vc = nvc.viewControllers.first! as! VoterListViewController
        vc.setup(proposal: proposal)
        return nvc
    }
    
    private func setup(proposal: Proposal) {
        self.proposal = proposal
        self.dataController = ProposalVotesDataController.shared(proposalId: proposal.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }
    
    fileprivate func refresh() {
        self.dataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    fileprivate func reloadData() {
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.allVotes.count == 0 {
            self.tableView.showNoResults(message: "No votes on this idea yet", icon: .lightbulb)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
    fileprivate var allVotes: [ProposalVote] {
        return self.dataController.allVotes
    }
    
}

extension VoterListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataController.donePaging ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.allVotes.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 76
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let vote = self.allVotes[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ResultCellId, for: indexPath) as! ProposalVoterCell
            cell.setup(vote: vote)
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let vote = self.allVotes[indexPath.row]
            
            let presentingVC = self.presentingViewController as? UINavigationController
            self.dismiss(animated: true) {
                let profileVC = ProfileViewController.create(profileId: vote.authorId)
                presentingVC?.pushViewController(profileVC, animated: true)
            }
        }
    }
    
}

extension VoterListViewController {
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.refresh()
    }
    
}

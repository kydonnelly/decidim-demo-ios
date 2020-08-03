//
//  VoterListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/2/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VoterListViewController: UIViewController {
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
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
    }
    
}

extension VoterListViewController {
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

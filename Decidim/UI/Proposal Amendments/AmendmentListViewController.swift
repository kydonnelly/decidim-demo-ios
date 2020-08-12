//
//  AmendmentListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/4/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class AmendmentListViewController: UIViewController {
    
    fileprivate static let AmendmentCellId = "AmendmentCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var proposalDetail: ProposalDetail!
    private var dataController: ProposalAmendmentDataController!
    
    static func create(proposalDetail: ProposalDetail) -> UIViewController {
        let sb = UIStoryboard(name: "AmendmentList", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! UINavigationController
        let alvc = nvc.viewControllers.first! as! AmendmentListViewController
        alvc.setup(proposalDetail: proposalDetail)
        return nvc
    }
    
    func setup(proposalDetail: ProposalDetail) {
        self.proposalDetail = proposalDetail
        self.dataController = ProposalAmendmentDataController.shared(proposalId: proposalDetail.proposal.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataController?.refresh(successBlock: { [weak self] dc in
            self?.tableView.reloadData()
        })
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
        }
    }
    
}

extension AmendmentListViewController {
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        let vc = CreateAmendmentViewController.create(proposal: self.proposalDetail)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension AmendmentListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataController?.allAmendments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.AmendmentCellId, for: indexPath) as! AmendmentCell
        
        let amendment = self.dataController.allAmendments[indexPath.row]
        cell.setup(amendment: amendment)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .white
    }
    
}

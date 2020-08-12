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
    fileprivate static let LoadingCellId = "LoadingCell"
    
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
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
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
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.dataController?.allAmendments.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.AmendmentCellId, for: indexPath) as! AmendmentCell
            
            let amendment = self.dataController.allAmendments[indexPath.row]
            cell.setup(amendment: amendment)
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard indexPath.section == 0 else { return }
        
        let amendment = self.dataController.allAmendments[indexPath.row]
        
        if amendment.authorId == MyProfileController.shared.myProfileId {
            let vc = CreateAmendmentViewController.create(proposal: self.proposalDetail, amendment: amendment)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if self.proposalDetail.authorId == MyProfileController.shared.myProfileId {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if amendment.status == .submitted {
                alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { [weak self] _  in
                    self?.selectStatus(.open, amendment: amendment)
                }))
                alert.addAction(UIAlertAction(title: "Invalidate", style: .default, handler: { [weak self] _  in
                    self?.selectStatus(.invalid, amendment: amendment)
                }))
            } else {
                alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] _  in
                    self?.selectStatus(.accepted, amendment: amendment)
                }))
                alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { [weak self] _  in
                    self?.selectStatus(.rejected, amendment: amendment)
                }))
            }
            
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = tableView
                presenter.sourceRect = tableView.rectForRow(at: indexPath)
            } else {
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak weakAlert = alert] _  in
                    weakAlert?.dismiss(animated: true, completion: nil)
                }))
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .white
    }
    
}

extension AmendmentListViewController {
    
    fileprivate func selectStatus(_ status: AmendmentStatus, amendment: ProposalAmendment) {
        self.dataController.editAmendment(amendment.amendmentId, status: status, text: amendment.text) { [weak self] error in
            guard error == nil else { return }
            
            self?.tableView.reloadData()
        }
    }
    
}

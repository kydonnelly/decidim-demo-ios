//
//  IssueFollowersViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 4/10/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueFollowersViewController: UIViewController, CustomTableController {
    
    private static let LoadingCellId = "LoadingCell"
    private static let FollowerCellId = "FollowerCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var issueDetail: IssueDetail!
    private var dataController: IssueFollowersDataController!
    
    public static func create(detail: IssueDetail) -> UINavigationController {
        let sb = UIStoryboard(name: "IssueFollowers", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! UINavigationController
        let vc = nvc.viewControllers.first as! IssueFollowersViewController
        vc.setup(detail: detail)
        return nvc
    }
    
    func setup(detail: IssueDetail) {
        self.issueDetail = detail
        self.dataController = IssueFollowersDataController.shared(issueId: detail.issue.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.dataController.refresh { [weak self] dc in
            self?.refreshData()
        }
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.refreshData()
        }
    }
    
    fileprivate func refreshData() {
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.dataController.allFollowers.count == 0 {
            self.tableView.showNoResults(message: "No one following", icon: .users)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
}

extension IssueFollowersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.dataController.allFollowers.count
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.FollowerCellId, for: indexPath) as! IssueFollowerCell
            
            let follower = self.dataController.allFollowers[indexPath.row]
            let profileInfos = ProfileInfoDataController.shared().data as? [ProfileInfo]
            let profileInfo = profileInfos?.first { $0.profileId == follower.userId }
            cell.setup(profile: profileInfo)

            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            guard let presentingVC = self.presentingViewController as? UINavigationController else {
                return
            }
            
            let follower = self.dataController.allFollowers[indexPath.row]
            
            self.dismiss(animated: true) {
                let vc = ProfileViewController.create(profileId: follower.userId)
                presentingVC.pushViewController(vc, animated: true)
            }
        }
    }
    
}

extension IssueFollowersViewController {
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

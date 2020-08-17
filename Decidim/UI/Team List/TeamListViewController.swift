//
//  TeamListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamListViewController: UIViewController {
    
    static let LoadingCellID = "LoadingCell"
    static let TeamDetailCellID = "TeamDetailCell"
    
    private var dataController: TeamListDataController!
    
    @IBOutlet var tableView: UITableView!
    
    public static func create() -> TeamListViewController {
        let sb = UIStoryboard(name: "TeamList", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! TeamListViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Browse Teams"
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.dataController = TeamListDataController.shared()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.dataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
        }
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
        }
    }
    
}

extension TeamListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController.donePaging {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.dataController.allTeams.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.TeamDetailCellID, for: indexPath)
            
            if let teamCell = cell as? TeamListCell {
                let team = self.dataController.allTeams[indexPath.row]
                teamCell.setup(team: team.team)
            }
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let team = self.dataController.allTeams[indexPath.row]
            let vc = TeamDetailViewController.create(team: team)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.dataController.page { [weak self] dc in
                self?.tableView.reloadData()
            }
        }
    }
    
}

extension TeamListViewController {
    
    @IBAction func tappedCreateButton(_ sender: UIButton) {
        let createVC = EditTeamViewController.create()
        createVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(createVC, animated: true, completion: nil)
    }
    
}

//
//  ExploreViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, CustomTableController {
    
    fileprivate enum Sections: CaseIterable {
        case issues
        case teams
        case people
        
        static func ordered() -> [Sections] {
            return [.issues, .teams, .people]
        }
        
        var title: String {
            switch self {
            case .issues: return "Topics"
            case .teams: return "Groups"
            case .people: return "People"
            }
        }
        
        var dataController: PreviewableDataController {
            switch self {
            case .issues: return PublicIssueDataController.shared()
            case .teams: return TeamListDataController.shared()
            case .people: return ProfileInfoDataController.shared()
            }
        }
        
        var creatable: Bool {
            switch self {
            case .issues: return false
            case .teams: return true
            case .people: return false
            }
        }
    }
    
    static let ExploreCellId = "ExploreCell"
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.tableView.reloadData()
    }
    
}

extension ExploreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Sections.ordered().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = Sections.ordered()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.ExploreCellId, for: indexPath) as! ExploreCell
        
        let onCreateBlock: ExploreCell.CreateBlock = {
            switch cellId {
            case .teams:
                let vc = EditTeamViewController.create()
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.present(vc, animated: true, completion: nil)
            case .issues:
                break
            case .people:
                break
            }
        }
        
        let onSelectBlock: ExploreListViewController.SelectBlock = { item in
            switch cellId {
                case .teams:
                    guard let teamDetail = item as? TeamDetail else { break }
                    let vc = TeamDetailViewController.create(team: teamDetail.team)
                    self.navigationController?.pushViewController(vc, animated: true)
                case .issues:
                    guard let issue = item as? Issue else { break }
                    let vc = IssueDetailViewController.create(issue: issue)
                    self.navigationController?.pushViewController(vc, animated: true)
                case .people:
                    guard let profile = item as? ProfileInfo else { break }
                    let vc = ProfileViewController.create(profileId: profile.profileId)
                    self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        cell.setup(title: cellId.title, dataController: cellId.dataController, showCreateButton: cellId.creatable, onSelect: onSelectBlock, onCreate: onCreateBlock)
        
        return cell
    }
    
}

extension ExploreViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 224
    }
    
}

extension ExploreViewController {
    
    @IBAction func tappedActivityButton(_ sender: UIBarButtonItem) {
        let vc = ActivityListViewController.create()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

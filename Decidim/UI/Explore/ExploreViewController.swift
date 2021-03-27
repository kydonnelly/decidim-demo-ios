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
            case .issues: return "Issues"
            case .teams: return "Groups"
            case .people: return "People I Follow"
            }
        }
        
        var dataController: PreviewableDataController {
            switch self {
            case .issues: return PublicIssueDataController.shared()
            case .teams: return TeamListDataController.shared()
            case .people: return ProfileInfoDataController.shared()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 224
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = Sections.ordered()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.ExploreCellId, for: indexPath) as! ExploreCell
        
        cell.setup(title: cellId.title, dataController: cellId.dataController, onSelect: nil)
        
        return cell
    }
    
}

extension ExploreViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellId = Sections.ordered()[indexPath.row]
        
        switch cellId {
        case .teams:
            let vc = TeamListViewController.create(profileId: MyProfileController.shared.myProfileId)
            self.navigationController?.pushViewController(vc, animated: true)
        case .issues:
            let vc = IssueListViewController.create()
            self.navigationController?.pushViewController(vc, animated: true)
        case .people:
            let vc = ProfileSearchViewController.create(category: "People I Follow", selectedProfileIds: [], onToggle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

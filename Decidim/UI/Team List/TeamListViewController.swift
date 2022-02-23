//
//  TeamListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamListViewController: UIViewController, CustomTableController {
    
    static let SectionHeaderID = "SectionHeader"
    static let LoadingCellID = "LoadingCell"
    static let TeamDetailCellID = "TeamDetailCell"
    
    fileprivate enum Sections: CaseIterable {
        case joined
        case invited
        case requested
        case recommended
        
        var title: String {
            switch self {
            case .joined: return "Joined"
            case .invited: return "Invited"
            case .requested: return "Requested"
            case .recommended: return "Recommended"
            }
        }
    }
    
    private var profileId: Int?
    private var dataController: TeamListDataController!
    
    @IBOutlet var tableView: UITableView!
    
    public static func create(profileId: Int?) -> TeamListViewController {
        let sb = UIStoryboard(name: "TeamList", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! UINavigationController
        let vc = nvc.viewControllers.first as! TeamListViewController
        vc.setup(profileId: profileId)
        return vc
    }
    
    private func setup(profileId: Int?) {
        self.profileId = profileId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.profileId == nil {
            self.profileId = MyProfileController.shared.myProfileId
        }
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(UINib(nibName: "TeamListHeaderView", bundle: .main),
                                forHeaderFooterViewReuseIdentifier: Self.SectionHeaderID)
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.dataController = TeamListDataController.shared()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.dataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    fileprivate func reloadData() {
        self.tableView.reloadData()
        
        if self.dataController.donePaging && self.dataController.allTeams.count == 0 {
            self.tableView.showNoResults(message: "No groups to display", icon: .users)
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.dataController.invalidate()
        self.dataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    fileprivate func teams(section: Sections) -> [Team] {
        guard let profileId = self.profileId else {
            return []
        }
        if profileId != MyProfileController.shared.myProfileId && section != .joined {
            return []
        }
        
        let memberStatus: TeamMemberStatus? = {
            switch section {
            case .invited: return .invited
            case .joined: return .active
            case .requested: return .requested
            case .recommended: return nil
            }
        }()
        
        return self.dataController.teams(profileId: profileId, status: memberStatus)
    }
    
}

extension TeamListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = Sections.allCases.count
        if !self.dataController.donePaging {
            numSections += 1
        }
        return numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < Sections.allCases.count else {
            return 1
        }
        return self.teams(section: Sections.allCases[section]).count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < Sections.allCases.count else {
            return 0
        }
        
        let section = Sections.allCases[section]
        guard self.teams(section: section).count > 0 else {
            return 0
        }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < Sections.allCases.count else {
            return nil
        }
        
        let section = Sections.allCases[section]
        guard self.teams(section: section).count > 0 else {
            return nil
        }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Self.SectionHeaderID) as! TeamListHeaderView
        header.setup(title: section.title)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < Sections.allCases.count {
            let section = Sections.allCases[indexPath.section]
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.TeamDetailCellID, for: indexPath) as! TeamListCell
            
            let team = self.teams(section: section)[indexPath.row]
            cell.setup(team: team, isMember: false, joinBlock: { [weak self] sender in
                 
            }, profileBlock: { [weak self] profileId in
                guard let navController = self?.navigationController else { return }
                let profileVC = ProfileViewController.create(profileId: profileId)
                navController.pushViewController(profileVC, animated: true)
            }, optionsBlock: { [weak self] sender in
                
            })

            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section < Sections.allCases.count {
            let section = Sections.allCases[indexPath.section]
            let team = self.teams(section: section)[indexPath.row]
            let vc = TeamDetailViewController.create(team: team)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == Sections.allCases.count {
            self.dataController.page { [weak self] dc in
                self?.reloadData()
            }
        }
    }
    
}

extension TeamListViewController {
    
    @IBAction func tappedCreateButton(_ sender: UIButton) {
        let createVC = EditTeamViewController.create()
        createVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(createVC, animated: true, completion: nil)
    }
    
}

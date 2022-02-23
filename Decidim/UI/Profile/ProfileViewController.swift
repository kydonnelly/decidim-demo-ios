//
//  ProfileViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, CustomTableController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var tabSectionHeader: UIView!
    @IBOutlet var tabOptionsBar: OptionsBar!
    
    internal var profileId: Int?
    private var profileDataController: ProfileInfoDataController!
    
    private var currentTab: ProfileTabSection!
    
    fileprivate enum State {
        case loading
        case noProfile
        case profile(ProfileInfo)
    }
    
    static let loadingCellId = "LoadingCell"
    static let usernameCellId = "UsernameCell"
    
    public static func create(profileId: Int) -> ProfileViewController {
        let sb = UIStoryboard(name: "Profile", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! UINavigationController
        let vc = nvc.viewControllers.first as! ProfileViewController
        vc.setup(profileId: profileId)
        return vc
    }
    
    private func setup(profileId: Int) {
        self.profileId = profileId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.profileId != nil {
            self.title = "Profile"
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.title = "My Profile"
            self.profileId = MyProfileController.shared.myProfileId
        }
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tabOptionsBar.setup(options: ["Groups", "Ideas", "Votes"], selectedIndex: nil) { [weak self] index in
            guard let self = self else { return }
            
            switch index {
            case 0: self.currentTab = ProfileTeamsTabSection()
            case 1: self.currentTab = ProfileProposalsTabSection()
            case 2: self.currentTab = ProfileVotesTabSection()
            default: preconditionFailure("Mismatch between selection bar and handler")
            }
            
            self.tableView.hideNoResultsIfNeeded()
            self.currentTab.setup(dataSource: self)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.layoutNoResultsView(below: 1)
    }
    
    fileprivate func refresh() {
        self.tableView.hideNoResultsIfNeeded()
        
        self.profileDataController = ProfileInfoDataController.shared()
        self.profileDataController.refresh { [weak self] dc in
            guard let self = self else { return }
            
            if let tab = self.currentTab {
                tab.refreshData()
            } else {
                self.tabOptionsBar.updateSelectedIndex(0, animated: false)
            }
        }
        
        VoteDelegationManager.shared.refresh { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    fileprivate var isMyProfile: Bool {
        return self.profileId != nil && self.profileId == MyProfileController.shared.myProfileId
    }
    
    fileprivate var state: State {
        guard let profiles = self.profileDataController?.data as? [ProfileInfo] else {
            return .loading
        }
        guard let currentId = self.profileId else {
            return .noProfile
        }
        guard let myInfo = profiles.first(where: { $0.profileId == currentId }) else {
            guard self.isMyProfile else {
                return .noProfile
            }
            guard let localHandle: String = MyProfileController.load(key: .username) else {
                return .noProfile
            }
            
            return .profile(ProfileInfo(profileId: currentId, handle: localHandle, thumbnailUrl: nil))
        }
        
        return .profile(myInfo)
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.state {
        case .loading:
            return 1
        case .noProfile:
            return 0
        case .profile:
            return 1 + (self.currentTab?.numberOfSections?(in: tableView) ?? 1)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if section == 1 {
            return 68
        } else {
            return self.currentTab?.tableView?(tableView, heightForHeaderInSection: section) ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return self.tabSectionHeader
        } else {
            return self.currentTab?.tableView?(tableView, viewForHeaderInSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.currentTab?.tableView(tableView, numberOfRowsInSection: section) ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch self.state {
            case .loading:
                return tableView.dequeueReusableCell(withIdentifier: Self.loadingCellId, for: indexPath)
            case .noProfile:
                preconditionFailure("No cell for missing profile")
            case let .profile(info):
                let nameCell = tableView.dequeueReusableCell(withIdentifier: Self.usernameCellId, for: indexPath) as! ProfileNameCell
                
                let isDelegate = VoteDelegationManager.shared.getDelegates(category: "Global").contains(info.profileId)
                
                nameCell.setup(profile: info, isDelegate: isDelegate) { [weak self] in
                    if isDelegate {
                        let preferencesVC = VotePreferencesViewController.create()
                        self?.navigationController?.pushViewController(preferencesVC, animated: true)
                    } else {
                        VoteDelegationManager.shared.updateDelegate(category: "Global", profileId: info.profileId) { [weak self] _ in
                            self?.refresh()
                        }
                    }
                }
                return nameCell
            }
        } else {
            return self.currentTab.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section != 0 {
            self.currentTab.tableView?(tableView, didSelectRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
        if indexPath.section != 0 {
            self.currentTab.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
    
}

// UIScrollViewDelegate
extension ProfileViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.tableView else { return }
        guard self.tableView.numberOfSections > self.sectionOffset else { return }
        
        // HACK: Fade in the header's shadow as the table scrolls into the tab section
        let tabHeaderOffset = self.tableView.rectForHeader(inSection: self.sectionOffset)
        let tableOffset = self.tableView.contentOffset.y + self.tableView.adjustedContentInset.top
        let scrollArea = Float(min(max(0.0, tableOffset - tabHeaderOffset.minY), 8.0))
        self.tabSectionHeader.layer.shadowOpacity = scrollArea * 0.125 * 0.167
    }
    
}

extension ProfileViewController: ProfileTabDataSource {
    
    var sectionOffset: Int {
        return 1
    }
    
    var loadingCellId: String {
        return Self.loadingCellId
    }
    
}

extension ProfileViewController {
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.profileDataController.invalidate()
        self.currentTab.invalidateData()
        self.refresh()
    }
    
}

extension ProfileViewController {
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        let settingsVC = SettingsViewController.create()
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func teamsButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Invitations", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let invitesVC = TeamInvitesViewController.create()
            self.navigationController?.pushViewController(invitesVC, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Join Requests", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let requestsVC = TeamJoinRequestViewController.create()
            self.navigationController?.pushViewController(requestsVC, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak weakAlert = alert] _  in
            weakAlert?.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

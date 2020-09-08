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
        } else {
            self.title = "My Profile"
            self.profileId = MyProfileController.shared.myProfileId
        }
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tabOptionsBar.setup(options: ["Teams", "Proposals", "Votes"], selectedIndex: nil) { [weak self] index in
            guard let self = self else { return }
            
            switch index {
            case 0: self.currentTab = ProfileTeamsTabSection()
            case 1: self.currentTab = ProfileProposalsTabSection()
            case 2: self.currentTab = ProfileVotesTabSection()
            default: preconditionFailure("Mismatch between selection bar and handler")
            }
            
            self.currentTab.setup(dataSource: self)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.currentTab == nil {
            self.tabOptionsBar.updateSelectedIndex(0, animated: false)
        }
        
        self.refresh()
    }
    
    fileprivate func refresh() {
        self.profileDataController = ProfileInfoDataController.shared()
        self.profileDataController.refresh { [weak self] dc in
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
            return 1 + (self.currentTab.numberOfSections?(in: tableView) ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else if section == 1 {
            return 44
        } else {
            return self.currentTab.tableView?(tableView, heightForHeaderInSection: section) ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return self.tabSectionHeader
        } else {
            return self.currentTab.tableView?(tableView, viewForHeaderInSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.currentTab.tableView(tableView, numberOfRowsInSection: section)
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
                nameCell.setup(profile: info)
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
        self.refresh()
    }
    
}

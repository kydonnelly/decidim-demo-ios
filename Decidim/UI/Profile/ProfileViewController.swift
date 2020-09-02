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
    
    private var profileDataController: ProfileInfoDataController!
    
    fileprivate enum State {
        case loading
        case noProfile
        case profile(ProfileInfo)
    }
    
    static let loadingCellId = "LoadingCell"
    static let registerCellId = "RegisterCell"
    static let usernameCellId = "UsernameCell"
    static let passwordCellId = "PasswordCell"
    static let teamsCellId = "TeamListCell"
    static let proposalsCellId = "ProposalListCell"
    static let votingCellId = "VotingCell"
    static let voteHistoryCellId = "VoteHistoryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Profile"
        
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }
    
    fileprivate func refresh() {
        self.profileDataController = ProfileInfoDataController.shared()
        self.profileDataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
        }
    }
    
    fileprivate var state: State {
        guard let myId = MyProfileController.shared.myProfileId else {
            return .noProfile
        }
        guard let profiles = self.profileDataController?.data as? [ProfileInfo] else {
            return .loading
        }
        guard let myInfo = profiles.first(where: { $0.profileId == myId }) else {
            guard let localHandle: String = MyProfileController.load(key: .username) else {
                return .noProfile
            }
            
            return .profile(ProfileInfo(profileId: myId, handle: localHandle, thumbnailUrl: nil))
        }
        
        return .profile(myInfo)
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.state {
        case .loading:
            return 1
        case .noProfile:
            return 1
        case .profile:
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.state {
        case .loading:
            return 44
        case .noProfile:
            return 72
        case .profile:
            break
        }
        
        if indexPath.row == 0 {
            return 76
        } else if indexPath.row >= 1 || indexPath.row <= 4 {
            return 44
        } else {
            preconditionFailure("Unexpected indexPath in ProfileViewController")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var profileInfo: ProfileInfo!
        
        switch self.state {
        case .loading:
            return tableView.dequeueReusableCell(withIdentifier: Self.loadingCellId, for: indexPath)
        case .noProfile:
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.registerCellId, for: indexPath) as! ProfileRegisterCell
            cell.setup { [weak self] in
                let registerVC = RegistrationViewController.create()
                registerVC.modalPresentationStyle = .fullScreen
                self?.navigationController?.present(registerVC, animated: true, completion: nil)
            }
            return cell
        case let .profile(info):
            profileInfo = info
            break
        }
        
        if indexPath.row == 0 {
            let nameCell = tableView.dequeueReusableCell(withIdentifier: Self.usernameCellId, for: indexPath) as! ProfileNameCell
            nameCell.setup(profile: profileInfo)
            return nameCell
        } else if indexPath.row == 1 {
            let passwordCell = tableView.dequeueReusableCell(withIdentifier: Self.passwordCellId, for: indexPath) as! ProfilePreferencesCell
            passwordCell.setup(title: "Password", detail: "Change")
            return passwordCell
        } else if indexPath.row == 2 {
            let proposalsCell = tableView.dequeueReusableCell(withIdentifier: Self.proposalsCellId, for: indexPath) as! ProfilePreferencesCell
            proposalsCell.setup(title: "My Proposals", detail: "See All")
            return proposalsCell
        } else if indexPath.row == 3 {
            let teamsCell = tableView.dequeueReusableCell(withIdentifier: Self.teamsCellId, for: indexPath) as! ProfilePreferencesCell
            teamsCell.setup(title: "My Teams", detail: "See All")
            return teamsCell
        } else if indexPath.row == 4 {
            let votingCell = tableView.dequeueReusableCell(withIdentifier: Self.votingCellId, for: indexPath) as! ProfilePreferencesCell
            votingCell.setup(title: "Voting Preferences", detail: "None")
            return votingCell
        } else if indexPath.row == 5 {
            let voteHistoryCell = tableView.dequeueReusableCell(withIdentifier: Self.voteHistoryCellId, for: indexPath) as! ProfilePreferencesCell
            voteHistoryCell.setup(title: "Voting History", detail: "See All")
            return voteHistoryCell
        } else {
            preconditionFailure("Unexpected indexPath in ProfileViewController")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch self.state {
        case .loading:
            return
        case .noProfile:
            return
        case .profile:
            break
        }
        
        if indexPath.row == 1 {
            let passwordVC = ProfilePasswordViewController.create()
            self.navigationController?.pushViewController(passwordVC, animated: true)
        } else if indexPath.row == 2 {
            let profileId = MyProfileController.shared.myProfileId
            let proposalListVC = ProposalListViewController.create(authorId: profileId)
            self.navigationController?.pushViewController(proposalListVC, animated: true)
        } else if indexPath.row == 3 {
            let teamListVC = TeamListViewController.create()
            self.navigationController?.pushViewController(teamListVC, animated: true)
        } else if indexPath.row == 4 {
            let preferencesVC = VotePreferencesViewController.create()
            self.navigationController?.pushViewController(preferencesVC, animated: true)
        } else if indexPath.row == 5 {
            let voteHistoryVC = VoteListViewController.create()
            self.navigationController?.pushViewController(voteHistoryVC, animated: true)
        }
    }
    
}

extension ProfileViewController {
    
    @objc public func pullToRefresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
        
        self.profileDataController.invalidate()
        self.refresh()
    }
    
}

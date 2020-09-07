//
//  SettingsViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, CustomTableController {
    
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
    static let votingCellId = "VotingCell"
    
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
        guard let profiles = self.profileDataController?.data as? [ProfileInfo] else {
            return .loading
        }
        guard let profileId = MyProfileController.shared.myProfileId else {
            return .noProfile
        }
        guard let myInfo = profiles.first(where: { $0.profileId == profileId }) else {
            guard let localHandle: String = MyProfileController.load(key: .username) else {
                return .noProfile
            }
            
            return .profile(ProfileInfo(profileId: profileId, handle: localHandle, thumbnailUrl: nil))
        }
        
        return .profile(myInfo)
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private var numberOfRows: Int {
        switch self.state {
        case .loading:
            return 1
        case .noProfile:
            return 1
        case .profile:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows
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
        } else if indexPath.row >= 1 && indexPath.row < self.numberOfRows {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.registerCellId, for: indexPath) as! SettingsRegisterCell
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
            let nameCell = tableView.dequeueReusableCell(withIdentifier: Self.usernameCellId, for: indexPath) as! SettingsProfileCell
            nameCell.setup(profile: profileInfo)
            return nameCell
        } else if indexPath.row == 1 {
            let passwordCell = tableView.dequeueReusableCell(withIdentifier: Self.passwordCellId, for: indexPath) as! SettingsPreferencesCell
            passwordCell.setup(title: "Password", detail: "Change")
            return passwordCell
        } else if indexPath.row == 2 {
            let votingCell = tableView.dequeueReusableCell(withIdentifier: Self.votingCellId, for: indexPath) as! SettingsPreferencesCell
            votingCell.setup(title: "Voting Preferences", detail: "None")
            return votingCell
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
            let passwordVC = ChangePasswordViewController.create()
            self.navigationController?.pushViewController(passwordVC, animated: true)
        } else if indexPath.row == 2 {
            let preferencesVC = VotePreferencesViewController.create()
            self.navigationController?.pushViewController(preferencesVC, animated: true)
        }
    }
    
}

//
//  ProfileViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    static let usernameCellId = "UsernameCell"
    static let passwordCellId = "PasswordCell"
    static let votingCellId = "VotingCell"
    static let voteHistoryCellId = "VoteHistoryCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Profile"
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 76
        } else if indexPath.row >= 1 || indexPath.row <= 3 {
            return 44
        } else {
            preconditionFailure("Unexpected indexPath in ProfileViewController")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let nameCell = tableView.dequeueReusableCell(withIdentifier: Self.usernameCellId, for: indexPath) as! ProfileNameCell
            nameCell.setup(profile: ProfileInfo(handle: "Test Username", thumbnailUrl: "https://kraken-api.herokuapp.com"))
            return nameCell
        } else if indexPath.row == 1 {
            let passwordCell = tableView.dequeueReusableCell(withIdentifier: Self.passwordCellId, for: indexPath) as! ProfilePreferencesCell
            passwordCell.setup(title: "Password", detail: "Change")
            return passwordCell
        } else if indexPath.row == 2 {
            let votingCell = tableView.dequeueReusableCell(withIdentifier: Self.votingCellId, for: indexPath) as! ProfilePreferencesCell
            votingCell.setup(title: "Voting Preferences", detail: "None")
            return votingCell
        } else if indexPath.row == 3 {
            let voteHistoryCell = tableView.dequeueReusableCell(withIdentifier: Self.voteHistoryCellId, for: indexPath) as! ProfilePreferencesCell
            voteHistoryCell.setup(title: "Voting History", detail: "See All")
            return voteHistoryCell
        } else {
            preconditionFailure("Unexpected indexPath in ProfileViewController")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let passwordVC = ProfilePasswordViewController.create()
            self.navigationController?.pushViewController(passwordVC, animated: true)
        } else if indexPath.row == 2 {
            let preferencesVC = VotePreferencesViewController.create()
            self.navigationController?.pushViewController(preferencesVC, animated: true)
        } else if indexPath.row == 3 {
            let voteHistoryVC = VoteListViewController.create()
            self.navigationController?.pushViewController(voteHistoryVC, animated: true)
        }
    }
    
}

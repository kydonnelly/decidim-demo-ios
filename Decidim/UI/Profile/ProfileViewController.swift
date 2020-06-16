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
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 76
        } else if indexPath.row == 1 {
            return 44
        } else if indexPath.row == 2 {
            return 44
        } else {
            preconditionFailure("Unexpected indexPath in ProfileViewController")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let nameCell = tableView.dequeueReusableCell(withIdentifier: Self.usernameCellId, for: indexPath) as! ProfileNameCell
            nameCell.setup(profile: ProfileInfo(handle: "Test", thumbnailUrl: "https://kraken-api.herokuapp.com"))
            return nameCell
        } else if indexPath.row == 1 {
            let passwordCell = tableView.dequeueReusableCell(withIdentifier: Self.passwordCellId, for: indexPath) as! ProfilePasswordCell
            return passwordCell
        } else if indexPath.row == 2 {
            let votingCell = tableView.dequeueReusableCell(withIdentifier: Self.votingCellId, for: indexPath) as! ProfilePreferencesCell
            return votingCell
        } else {
            preconditionFailure("Unexpected indexPath in ProfileViewController")
        }
    }
    
}

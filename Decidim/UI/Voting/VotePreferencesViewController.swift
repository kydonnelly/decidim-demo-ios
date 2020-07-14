//
//  VotePreferencesViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VotePreferencesViewController: UIViewController {
    
    static let toggleCellId = "ToggleCell"
    static let delegationCellId = "DelegationCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var togglePreferences: [String: Bool] = ["Public Votes": false, "Receive Notifications": true]
    private var delegationPreferences: [String] = ["Transportation", "Housing", "Environmental", "Public Safety"]
    
    public static func create() -> VotePreferencesViewController {
        let sb = UIStoryboard(name: "VotePreferences", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! VotePreferencesViewController
        return vc
    }
    
}

extension VotePreferencesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.togglePreferences.count
        } else {
            return self.delegationPreferences.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 48
        } else {
            return 76
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let title = self.togglePreferences.keys.sorted()[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.toggleCellId, for: indexPath) as! VotePreferencesToggleCell
            cell.setup(title: title, isOn: self.togglePreferences[title]!) { [weak self] isOn in
                self?.togglePreferences[title] = isOn
            }
            return cell
        } else {
            let category = self.delegationPreferences[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.delegationCellId, for: indexPath) as! VotePreferencesDelegateCell
            cell.setup(category: category, profiles: [])
            return cell
        }
    }
    
}

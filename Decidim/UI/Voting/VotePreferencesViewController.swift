//
//  VotePreferencesViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class VotePreferencesViewController: UIViewController, CustomTableController {
    
    static let toggleCellId = "ToggleCell"
    static let delegationCellId = "DelegationCell"
    static let loadingCellId = "LoadingCell"
    
    @IBOutlet var tableView: UITableView!
    
    private var togglePreferences: [String: Bool] = ["Public Votes": false, "Receive Notifications": true]
    
    public static func create() -> VotePreferencesViewController {
        let sb = UIStoryboard(name: "VotePreferences", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! VotePreferencesViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        VoteDelegationManager.shared.refresh { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
}

extension VotePreferencesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.togglePreferences.count
        } else if VoteDelegationManager.shared.doneLoading {
            return VoteDelegationManager.shared.allCategories.count
        } else {
            return 1
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
        } else if VoteDelegationManager.shared.doneLoading {
            let category = VoteDelegationManager.shared.allCategories[indexPath.row]
            let delegates = VoteDelegationManager.shared.getDelegates(category: category)
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.delegationCellId, for: indexPath) as! VotePreferencesDelegateCell
            cell.setup(category: category, delegates: delegates) { [weak self] profileId in
                guard let navController = self?.navigationController else { return }
                let profileVC = ProfileViewController.create(profileId: profileId)
                navController.pushViewController(profileVC, animated: true)
            }
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.loadingCellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            return
        } else if VoteDelegationManager.shared.doneLoading {
            let category = VoteDelegationManager.shared.allCategories[indexPath.row]
            let delegates = VoteDelegationManager.shared.getDelegates(category: category)
            let vc = ProfileSearchViewController.create(title: category, selectedProfileId: delegates.first) { [weak self] toggledId, selectedId in
                VoteDelegationManager.shared.updateDelegate(category: category, profileId: selectedId) { [weak self] _ in
                    self?.tableView.reloadData()
                }
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

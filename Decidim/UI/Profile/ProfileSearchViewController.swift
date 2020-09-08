//
//  ProfileSearchViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/29/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileSearchViewController: UIViewController, CustomTableController {
    
    public typealias ToggleBlock = (Int, [Int]) -> Void
    
    @IBOutlet var tableView: UITableView!
    
    private var selectedProfileIds: [Int]!
    private var profileInfoDataController: ProfileInfoDataController!
    private var toggleBlock: ToggleBlock?
    
    fileprivate var currentFilter: String?
    
    private static let LoadingCellId = "LoadingCell"
    private static let ResultCellId = "ProfileResultCell"
    
    static func create(category: String, selectedProfileIds: [Int], onToggle: ToggleBlock?) -> ProfileSearchViewController {
        let sb = UIStoryboard(name: "ProfileSearch", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! ProfileSearchViewController
        vc.setup(selectedProfileIds: selectedProfileIds, onToggle: onToggle)
        vc.title = category
        return vc
    }
    
    private func setup(selectedProfileIds: [Int], onToggle: ToggleBlock?) {
        self.selectedProfileIds = selectedProfileIds
        self.profileInfoDataController = ProfileInfoDataController.shared()
        self.toggleBlock = onToggle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.profileInfoDataController.refresh { [weak self] dc in
            self?.reloadData()
        }
    }
    
    fileprivate func reloadData() {
        self.tableView.reloadData()
        
        if self.profileInfoDataController.donePaging && self.profileInfos?.count == 0 {
            self.tableView.showNoResults(message: "No search results")
        } else {
            self.tableView.hideNoResultsIfNeeded()
        }
    }
    
    fileprivate var profileInfos: [ProfileInfo]? {
        guard let infos = self.profileInfoDataController.data as? [ProfileInfo] else {
            return nil
        }
        
        guard let filter = self.currentFilter, filter.count > 0 else {
            return infos
        }
        
        return infos.filter { $0.handle.lowercased().contains(filter.lowercased()) }
    }
    
}

extension ProfileSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let infos = self.profileInfos else {
            return 1
        }
        return infos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard self.profileInfos != nil else {
            return 44
        }
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let infos = self.profileInfos else {
            return tableView.dequeueReusableCell(withIdentifier: Self.LoadingCellId, for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.ResultCellId, for: indexPath) as! ProfileSearchResultCell
        
        let info = infos[indexPath.row]
        let isSelected = self.selectedProfileIds.contains(info.profileId)
        
        cell.setup(profile: info, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let infos = self.profileInfos else {
            return
        }
        
        let profileId = infos[indexPath.row].profileId
        if let index = self.selectedProfileIds.firstIndex(of: profileId) {
            self.selectedProfileIds.remove(at: index)
        } else {
            self.selectedProfileIds.append(profileId)
        }
        
        self.toggleBlock?(profileId, self.selectedProfileIds)
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}

extension ProfileSearchViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.currentFilter = textField.text
        self.reloadData()
    }
    
}

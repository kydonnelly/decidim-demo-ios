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
    private var allowsMultipleSelection: Bool = false
    private var profileInfoDataController: ProfileInfoDataController!
    private var toggleBlock: ToggleBlock?
    
    fileprivate var currentFilter: String?
    
    private static let LoadingCellId = "LoadingCell"
    private static let ResultCellId = "ProfileResultCell"
    
    private static func create() -> ProfileSearchViewController {
        let sb = UIStoryboard(name: "ProfileSearch", bundle: .main)
        return sb.instantiateInitialViewController() as! ProfileSearchViewController
    }
    
    // Create with only a single profile able to be selected at a time
    static func create(title: String, selectedProfileId: Int?, onToggle: ((Int, Int?) -> Void)?) -> ProfileSearchViewController {
        let vc = self.create()
        let selected = [selectedProfileId].compactMap {$0}
        vc.setup(title: title, selectedProfileIds: selected, allowMultiSelect: false) { updated, selected in
            onToggle?(updated, selected.first)
        }
        return vc
    }
    
    // Create with multiple profiles able to be selected at a time
    static func create(title: String, selectedProfileIds: [Int], onToggle: ToggleBlock?) -> ProfileSearchViewController {
        let vc = self.create()
        vc.setup(title: title, selectedProfileIds: selectedProfileIds, allowMultiSelect: true, onToggle: onToggle)
        return vc
    }
    
    private func setup(title: String, selectedProfileIds: [Int], allowMultiSelect: Bool, onToggle: ToggleBlock?) {
        self.title = title
        self.selectedProfileIds = selectedProfileIds
        self.allowsMultipleSelection = allowMultiSelect
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
            self.tableView.showNoResults(message: "No search results to display", icon: .search)
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
        
        var reloadPaths = [indexPath]
        
        let profileId = infos[indexPath.row].profileId
        if let index = self.selectedProfileIds.firstIndex(of: profileId) {
            // Already selected; deselect
            self.selectedProfileIds.remove(at: index)
            reloadPaths.append(IndexPath(row: index, section: 0))
        } else if self.allowsMultipleSelection {
            // Add to multi-selection
            self.selectedProfileIds.append(profileId)
        } else {
            // New single selection; deselect all others
            let selectedIndexes = infos.enumerated().filter{ self.selectedProfileIds.contains($1.profileId) }.map { IndexPath(row: $0.offset, section: 0) }
            reloadPaths.append(contentsOf: selectedIndexes)
            self.selectedProfileIds = [profileId]
        }
        
        self.toggleBlock?(profileId, self.selectedProfileIds)
        
        tableView.reloadRows(at: reloadPaths, with: .none)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
}

extension ProfileSearchViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.currentFilter = textField.text
        self.reloadData()
    }
    
}

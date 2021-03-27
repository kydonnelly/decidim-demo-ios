//
//  ExploreListViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ExploreListViewController: HorizontalListViewController {
    
    typealias SelectBlock = (Proposal) -> Void
    
    static let previewCellId = "PreviewCell"
    static let loadingCellId = "LoadingCell"
    
    private var selectBlock: SelectBlock?
    
    private var dataController: PreviewableDataController? = nil
    
    public static func create() -> ExploreListViewController {
        let sb = UIStoryboard(name: "ExploreList", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! ExploreListViewController
        return vc
    }
    
    public func setup(dataController: PreviewableDataController, onSelect: SelectBlock?) {
        self.selectBlock = onSelect
        
        self.dataController = dataController
        dataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
        }
        
        self.tableView.reloadData()
    }
    
}

extension ExploreListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataController?.donePaging == true {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.dataController?.previewItems.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 128
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.previewCellId, for: indexPath) as! ExploreListPreviewCell
            
            let previewItem = self.dataController!.previewItems[indexPath.row]
            cell.setup(item: previewItem)
            
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: Self.loadingCellId, for: indexPath)
        }
    }
    
}

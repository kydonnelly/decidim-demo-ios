//
//  ExploreCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ExploreCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var containerView: UIView!
    
    private var childViewController: ExploreListViewController! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.childViewController = ExploreListViewController.create()
        self.containerView.addSubview(self.childViewController.view)
        self.childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.childViewController.view.frame = self.containerView.bounds
    }
    
    public func setup(title: String, dataController: PreviewableDataController, onSelect: ExploreListViewController.SelectBlock?) {
        self.titleLabel.text = title
        self.childViewController.setup(dataController: dataController, onSelect: onSelect)
    }
    
}

//
//  ExploreCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ExploreCell: UITableViewCell {
    
    typealias CreateBlock = () -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var createButton: UIButton!
    
    private var createBlock: CreateBlock?
    
    private var childViewController: ExploreListViewController! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.childViewController = ExploreListViewController.create()
        self.containerView.addSubview(self.childViewController.view)
        self.childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.childViewController.view.frame = self.containerView.bounds
    }
    
    public func setup(title: String, dataController: PreviewableDataController, showCreateButton: Bool, onSelect: ExploreListViewController.SelectBlock?, onCreate: CreateBlock? = nil) {
        self.titleLabel.text = title
        self.createButton.isHidden = !showCreateButton
        self.createBlock = onCreate
        
        self.childViewController.setup(dataController: dataController, onSelect: onSelect)
    }
    
}

extension ExploreCell {
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        self.createBlock?()
    }
    
}

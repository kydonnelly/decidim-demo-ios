//
//  IssueDetailProposalListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/24/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueDetailProposalListCell: UITableViewCell {
    
    @IBOutlet var containerView: UIView!
    private var childViewController: IssueDetailProposalListViewController! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.childViewController = IssueDetailProposalListViewController.create()
        self.containerView.addSubview(self.childViewController.view)
        self.childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.childViewController.view.frame = self.containerView.bounds
    }
    
    public func setup(detail: IssueDetail, onCreate: IssueDetailProposalListViewController.CreateBlock?, onExpand: IssueDetailProposalListViewController.ExpandBlock?) {
        self.childViewController.setup(detail: detail, onCreate: onCreate, onExpand: onExpand)
    }
    
}

//
//  TeamIssueListCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/11/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamIssueListCell: CustomTableViewCell {
    
    typealias CreateBlock = () -> Void
    typealias IssueBlock = (Issue) -> Void
    
    @IBOutlet var createButton: UIButton!
    @IBOutlet var numIssuesLabel: UILabel!
    @IBOutlet var issueListView: IssueIconListView!
    @IBOutlet var listViewConstraints: [NSLayoutConstraint]!
    
    private var createBlock: CreateBlock?
    
    func setup(detail: TeamDetail, canCreate: Bool, createBlock: CreateBlock?, tappedIssueBlock: IssueBlock?) {
        self.createBlock = createBlock
        self.createButton.isHidden = !canCreate
        self.numIssuesLabel.text = "TOPICS"

        let dc = PublicIssueDataController.shared()
        dc.refresh { [weak self, weak wdc = dc] _ in
            guard let self = self, let dataController = wdc else { return }
            
            let issues = dataController.allIssues.filter { $0.teamId == detail.team.id }
            self.issueListView.setup(issues: issues, tappedIssueBlock: { issue in
                tappedIssueBlock?(issue)
            })
            
            self.numIssuesLabel.text = "TOPICS: \(issues.count)"
            self.listViewConstraints.forEach { $0.isActive = issues.count > 0 }
        }
    }
    
    @IBAction func tappedCreateButton(_ sender: UIButton) {
        self.createBlock?()
    }
    
}


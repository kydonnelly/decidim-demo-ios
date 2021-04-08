//
//  EditProposalViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class EditProposalViewController: UIViewController, CustomTableController {
    
    fileprivate static let ActionCellId = "ActionCell"
    fileprivate static let TitleCellId = "TitleCell"
    fileprivate static let BodyCellId = "BodyCell"
    fileprivate static let DateCellId = "DateCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButtonItem: UIBarButtonItem!
    
    fileprivate var associatedIssue: IssueDetail?
    fileprivate var originalProposal: ProposalDetail?
    
    fileprivate var proposalTitle: String? {
        didSet { refreshDoneButton() }
    }
    fileprivate var proposalDescription: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var amendmentDeadline: Date!
    fileprivate var votingDeadline: Date!
    
    public static func create(proposal: ProposalDetail) -> UIViewController {
        let sb = UIStoryboard(name: "EditProposal", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        let epvc = vc.viewControllers.first! as! EditProposalViewController
        epvc.setup(proposal: proposal, issue: nil)
        return vc
    }
    
    public static func create(issue: IssueDetail) -> UIViewController {
        let sb = UIStoryboard(name: "EditProposal", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        let epvc = vc.viewControllers.first! as! EditProposalViewController
        epvc.setup(proposal: nil, issue: issue)
        return vc
    }
    
    private func setup(proposal: ProposalDetail?, issue: IssueDetail?) {
        self.associatedIssue = issue
        self.originalProposal = proposal
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.autoInsetForKeyboard()
        
        self.tableView.register(UINib(nibName: "DatePickerCell", bundle: .main),
                                forCellReuseIdentifier: Self.DateCellId)
        self.tableView.register(UINib(nibName: "MultiLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.BodyCellId)
        self.tableView.register(UINib(nibName: "SingleLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.TitleCellId)
        
        if let editingProposal = self.originalProposal {
            self.title = "Edit Proposal"
            self.amendmentDeadline = editingProposal.proposal.amendmentDeadline ?? self.defaultDeadline
            self.votingDeadline = editingProposal.proposal.votingDeadline ?? self.defaultDeadline
            self.proposalTitle = editingProposal.proposal.title
            self.proposalDescription = editingProposal.proposal.body
        } else {
            self.refreshDoneButton()
            self.votingDeadline = self.defaultDeadline
            self.amendmentDeadline = self.defaultDeadline
        }
    }
    
    private var defaultDeadline: Date {
        return Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
    }
    
}

extension EditProposalViewController {
    
    fileprivate var hasValidInput: Bool {
        guard let title = self.proposalTitle, title.count > 0 else {
            return false
        }
        
        guard let description = self.proposalDescription, description.count > 0 else {
            return false
        }
        
        return true
    }
    
    fileprivate func refreshDoneButton() {
        self.doneButtonItem.isEnabled = self.hasValidInput
        self.tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
    }
    
}

extension EditProposalViewController {
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        if let editingProposalId = self.originalProposal?.proposal.id {
            self.submitEditedProposal(id: editingProposalId)
        } else {
            self.submitNewProposal()
        }
    }
    
    private func submitNewProposal() {
        guard let title = self.proposalTitle, let description = self.proposalDescription else {
            return
        }
        
        guard let issueId = self.associatedIssue?.issue.id else {
            return
        }
        
        self.blockView(message: "Submitting proposal...")
        PublicProposalDataController.shared().addProposal(issueId: issueId, title: title, description: description, amendmentDeadline: self.amendmentDeadline, votingDeadline: self.votingDeadline) { [weak self] error in
            self?.unblockView()
            
            guard error == nil else {
                return
            }
            
            guard let proposal = PublicProposalDataController.shared().allProposals.first else {
                return
            }
            
            ProposalDetailDataController.shared(proposal: proposal).refresh { dc in
                dc.data = [ProposalDetail(proposal: proposal, voteCount: 0, commentCount: 0, amendmentCount: 0)]
            }
        }
    }
    
    private func submitEditedProposal(id: Int) {
        guard let title = self.proposalTitle, let description = self.proposalDescription else {
            return
        }
        
        guard let issueId = self.originalProposal?.proposal.issueId else {
            return
        }
        
        self.blockView(message: "Editing proposal...")
        PublicProposalDataController.shared().editProposal(id, issueId: issueId, title: title, description: description, amendmentDeadline: self.amendmentDeadline, votingDeadline: self.votingDeadline) { [weak self] error in
            self?.unblockView()
            
            guard error == nil else {
                return
            }
            
            guard let proposal = PublicProposalDataController.shared().allProposals.first(where: { $0.id == id }) else {
                return
            }
            
            ProposalDetailDataController.shared(proposal: proposal).refresh { dc in
                dc.data = [ProposalDetail(proposal: proposal, voteCount: 0, commentCount: 0, amendmentCount: 0)]
            }
        }
    }
    
}

extension EditProposalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        } else if indexPath.row == 1 {
            return 120
        } else if indexPath.row == 2 || indexPath.row == 3 {
            return 128
        } else {
            return 72
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.TitleCellId, for: indexPath) as! SingleLineEntryCell
            cell.setup(field: "Title", content: self.proposalTitle, required: true) { [weak self] text in
                self?.proposalTitle = text
                return true
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.BodyCellId, for: indexPath) as! MultiLineEntryCell
            cell.setup(field: "Description", content: self.proposalDescription) { [weak self] text in
                self?.proposalDescription = text
                return true
            }
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.DateCellId, for: indexPath) as! DatePickerCell
            cell.setup(title: "Amendment Deadline", deadline: self.amendmentDeadline) { [weak self] date in
                self?.amendmentDeadline = date
            }
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.DateCellId, for: indexPath) as! DatePickerCell
            cell.setup(title: "Voting Deadline", deadline: self.votingDeadline) { [weak self] date in
                self?.votingDeadline = date
            }
            return cell
        } else {
            let actionTitle = self.originalProposal == nil ? "Create Proposal" : "Save Changes"
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ActionCellId, for: indexPath) as! SingleActionCell
            cell.setup(action: actionTitle, isEnabled: self.hasValidInput) { [weak self] sender in
                self?.didTapDoneButton(sender)
            }
            return cell
        }
    }
    
}

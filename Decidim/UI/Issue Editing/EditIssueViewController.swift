//
//  EditIssueViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import GiphyUISDK
import UIKit

class EditIssueViewController: UIViewController, CustomTableController {
    
    fileprivate static let ActionCellId = "ActionCell"
    fileprivate static let ImageCellId = "ImageCell"
    fileprivate static let TitleCellId = "TitleCell"
    fileprivate static let BodyCellId = "BodyCell"
    fileprivate static let DateCellId = "DateCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButtonItem: UIBarButtonItem!
    
    fileprivate var originalIssue: IssueDetail?
    fileprivate var associatedTeamId: Int!
    
    fileprivate var issueTitle: String? {
        didSet { refreshDoneButton() }
    }
    fileprivate var issueDescription: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var thumbnailMediaId: String?
    fileprivate var deadline: Date!
    
    public static func create(teamId: Int, issue: IssueDetail? = nil) -> UIViewController {
        let sb = UIStoryboard(name: "EditIssue", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        let epvc = vc.viewControllers.first! as! EditIssueViewController
        epvc.setup(teamId: teamId, issue: issue)
        return vc
    }
    
    private func setup(teamId: Int, issue: IssueDetail?) {
        self.originalIssue = issue
        self.associatedTeamId = teamId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.autoInsetForKeyboard()
        
        self.tableView.register(UINib(nibName: "DatePickerCell", bundle: .main),
                                forCellReuseIdentifier: Self.DateCellId)
        self.tableView.register(UINib(nibName: "EditImageCell", bundle: .main),
                                forCellReuseIdentifier: Self.ImageCellId)
        self.tableView.register(UINib(nibName: "MultiLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.BodyCellId)
        self.tableView.register(UINib(nibName: "SingleLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.TitleCellId)
        
        if let editingIssue = self.originalIssue {
            self.title = "Edit Topic"
            self.deadline = editingIssue.issue.deadline ?? Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
            self.issueTitle = editingIssue.issue.title
            self.issueDescription = editingIssue.issue.body
            self.thumbnailMediaId = editingIssue.issue.iconUrl
        } else {
            self.refreshDoneButton()
            self.deadline = Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
        }
    }
    
}

extension EditIssueViewController {
    
    fileprivate var hasValidInput: Bool {
        guard let title = self.issueTitle, title.count > 0 else {
            return false
        }
        
        guard let description = self.issueDescription, description.count > 0 else {
            return false
        }
        
        return true
    }
    
    fileprivate func refreshDoneButton() {
        self.doneButtonItem.isEnabled = self.hasValidInput
        self.tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
    }
    
}

extension EditIssueViewController {
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        let completion: () -> Void = { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        if let editingIssueId = self.originalIssue?.issue.id {
            self.submitEditedIssue(id: editingIssueId, completion: completion)
        } else {
            self.submitNewIssue(completion: completion)
        }
    }
    
    private func submitNewIssue(completion: (() -> Void)?) {
        guard let title = self.issueTitle, let description = self.issueDescription else {
            return
        }
        
        self.blockView(message: "Submitting topic...")
        PublicIssueDataController.shared().addIssue(title: title, description: description, teamId: self.associatedTeamId, thumbnailUrl: self.thumbnailMediaId, deadline: self.deadline) { [weak self] error in
            self?.unblockView()
            
            defer {
                completion?()
            }
            
            guard error == nil else {
                return
            }
            
            guard let issue = PublicIssueDataController.shared().allIssues.first else {
                return
            }
            
            IssueDetailDataController.shared(issue: issue).data = [IssueDetail(issue: issue, proposalIds: [], commentCount: 0, followersCount: 0)]
        }
    }
    
    private func submitEditedIssue(id: Int, completion: (() -> Void)?) {
        guard let detail = self.originalIssue else {
            return
        }
        guard let title = self.issueTitle, let description = self.issueDescription else {
            return
        }
        
        self.blockView(message: "Editing issue...")
        PublicIssueDataController.shared().editIssue(id, title: title, description: description, teamId: self.associatedTeamId, thumbnailUrl: self.thumbnailMediaId, deadline: self.deadline) { [weak self] error in
            self?.unblockView()
            
            defer {
                completion?()
            }
            
            guard error == nil else {
                return
            }
            
            guard let issue = PublicIssueDataController.shared().allIssues.first(where: { $0.id == id }) else {
                return
            }
            
            IssueDetailDataController.shared(issue: issue).data = [IssueDetail(issue: issue, proposalIds: detail.proposalIds, commentCount: detail.commentCount, followersCount: detail.followersCount)]
        }
    }
    
}

extension EditIssueViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            return 112
        } else if indexPath.row == 2 {
            return 128
        } else if indexPath.row == 3 {
            return 120
        } else {
            return 72
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.TitleCellId, for: indexPath) as! SingleLineEntryCell
            cell.setup(field: "Title", content: self.issueTitle, required: true) { [weak self] text in
                self?.issueTitle = text
                return true
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ImageCellId, for: indexPath) as! EditImageCell
            cell.setup(thumbnailUrl: self.thumbnailMediaId) { [weak self] in
                self?.showImagePicker(indexPath: indexPath)
            }
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.DateCellId, for: indexPath) as! DatePickerCell
            cell.setup(title: "Deadline", deadline: self.deadline) { [weak self] date in
                self?.deadline = date
            }
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.BodyCellId, for: indexPath) as! MultiLineEntryCell
            cell.setup(field: "Description", content: self.issueDescription) { [weak self] text in
                self?.issueDescription = text
                return true
            }
            return cell
        } else {
            let actionTitle = self.originalIssue == nil ? "Create Topic" : "Save Changes"
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ActionCellId, for: indexPath) as! SingleActionCell
            cell.setup(action: actionTitle, isEnabled: self.hasValidInput) { [weak self] sender in
                self?.didTapDoneButton(sender)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            self.showImagePicker(indexPath: indexPath)
        }
    }
    
}

extension EditIssueViewController: GiphyDelegate {
    
    fileprivate func showImagePicker(indexPath: IndexPath) {
        let imagePicker = GiphyManager.shared.giphyViewController(delegate: self)
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        self.thumbnailMediaId = media.id
        
        giphyViewController.dismiss(animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func didDismiss(controller: GiphyViewController?) {
        self.tableView.reloadData()
    }
    
}

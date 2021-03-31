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
    
    fileprivate static let InputCellId = "InputCell"
    fileprivate static let ImageCellId = "ImageCell"
    fileprivate static let DateCellId = "DateCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButtonItem: UIBarButtonItem!
    
    fileprivate var originalIssue: IssueDetail?
    
    fileprivate var issueTitle: String? {
        didSet { refreshDoneButton() }
    }
    fileprivate var issueDescription: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var thumbnailMediaId: String?
    fileprivate var deadline: Date!
    
    public static func create(issue: IssueDetail? = nil) -> UIViewController {
        let sb = UIStoryboard(name: "EditIssue", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        let epvc = vc.viewControllers.first! as! EditIssueViewController
        epvc.setup(issue: issue)
        return vc
    }
    
    private func setup(issue: IssueDetail?) {
        self.originalIssue = issue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let editingIssue = self.originalIssue {
            self.title = "Edit Issue"
            self.deadline = editingIssue.deadline ?? Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
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
    
    fileprivate func refreshDoneButton() {
        if let title = self.issueTitle, title.count > 0,
           let description = self.issueDescription, description.count > 0 {
            self.doneButtonItem.isEnabled = true
        } else {
            self.doneButtonItem.isEnabled = false
        }
    }
    
}

extension EditIssueViewController {
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
        if let editingIssueId = self.originalIssue?.issue.id {
            self.submitEditedIssue(id: editingIssueId)
        } else {
            self.submitNewIssue()
        }
    }
    
    private func submitNewIssue() {
        let deadline: Date = self.deadline
        guard let title = self.issueTitle, let description = self.issueDescription else {
            return
        }
        
        self.blockView(message: "Submitting issue...")
        PublicIssueDataController.shared().addIssue(title: title, description: description, thumbnailUrl: self.thumbnailMediaId, deadline: self.deadline) { [weak self] error in
            self?.unblockView()
            
            guard error == nil else {
                return
            }
            
            guard let issue = PublicIssueDataController.shared().allIssues.first else {
                return
            }
            
            IssueDetailDataController.shared(issue: issue).refresh { dc in
                dc.data = [IssueDetail(issue: issue, deadline: deadline, proposalIds: [], commentCount: 0, followersCount: 0, userIsFollowing: true)]
            }
        }
    }
    
    private func submitEditedIssue(id: Int) {
        let deadline: Date = self.deadline
        guard let detail = self.originalIssue else {
            return
        }
        guard let title = self.issueTitle, let description = self.issueDescription else {
            return
        }
        
        self.blockView(message: "Editing issue...")
        PublicIssueDataController.shared().editIssue(id, title: title, description: description, thumbnailUrl: self.thumbnailMediaId, deadline: self.deadline) { [weak self] error in
            self?.unblockView()
            
            guard error == nil else {
                return
            }
            
            guard let issue = PublicIssueDataController.shared().allIssues.first(where: { $0.id == id }) else {
                return
            }
            
            IssueDetailDataController.shared(issue: issue).refresh { dc in
                dc.data = [IssueDetail(issue: issue, deadline: deadline, proposalIds: detail.proposalIds, commentCount: detail.commentCount, followersCount: detail.followersCount, userIsFollowing: true)]
            }
        }
    }
    
}

extension EditIssueViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        } else if indexPath.row == 1 {
            return 112
        } else if indexPath.row == 2 {
            return 128
        } else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InputCellId, for: indexPath) as! IssueInputCell
            cell.setup(field: "Title", content: self.issueTitle, required: true) { [weak self] text in
                self?.issueTitle = text
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InputCellId, for: indexPath) as! IssueInputCell
            cell.setup(field: "Description", content: self.issueDescription, required: true) { [weak self] text in
                self?.issueDescription = text
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

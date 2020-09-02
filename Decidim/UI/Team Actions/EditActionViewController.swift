//
//  EditActionViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class EditActionViewController: UIViewController, CustomTableController {
    
    fileprivate static let InputCellId = "InputCell"
    fileprivate static let ToggleCellId = "ToggleCell"
    fileprivate static let DateCellId = "DateCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButtonItem: UIBarButtonItem!
    
    fileprivate var teamDetail: TeamDetail!
    fileprivate var originalAction: String?
    
    fileprivate var actionDescription: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var deadline: Date!
    fileprivate var isOngoing: Bool = false
    
    public static func create(detail: TeamDetail, action: String? = nil) -> UIViewController {
        let sb = UIStoryboard(name: "EditAction", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        let eavc = vc.viewControllers.first! as! EditActionViewController
        eavc.setup(detail: detail, action: action)
        return vc
    }
    
    private func setup(detail: TeamDetail, action: String?) {
        self.teamDetail = detail
        self.originalAction = action
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let editingAction = self.originalAction {
            self.actionDescription = editingAction
//            self.deadline = editingAction.deadline
            self.deadline = Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
        } else {
            self.refreshDoneButton()
            self.deadline = Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
        }
    }
    
}

extension EditActionViewController {
    
    fileprivate func refreshDoneButton() {
        if let description = self.actionDescription, description.count > 0 {
            self.doneButtonItem.isEnabled = true
        } else {
            self.doneButtonItem.isEnabled = false
        }
    }
    
}

extension EditActionViewController {
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        if let editingAction = self.originalAction {
            self.submitEditedAction(editingAction)
        } else {
            self.submitNewAction()
        }
    }
    
    private func submitNewAction() {
        guard let description = self.actionDescription, description.count > 0 else {
            return
        }
        
        let newStatus: TeamActionStatus = self.isOngoing ? .ongoing : .pending
        var teamActions = self.teamDetail.actionList
        teamActions[description] = newStatus
        
        TeamListDataController.shared().editTeam(self.teamDetail.team.id, title: self.teamDetail.team.name, description: self.teamDetail.team.description, thumbnail: self.teamDetail.team.thumbnail, members: self.teamDetail.memberList, actions: teamActions) { [weak self] error in
            guard error == nil else {
                return
            }
            
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func submitEditedAction(_ originalDescription: String) {
        guard let description = self.actionDescription, description.count > 0 else {
            return
        }
        
        var teamActions = self.teamDetail.actionList
        let status = teamActions[originalDescription]
        teamActions.removeValue(forKey: originalDescription)
        teamActions[description] = status
        
        TeamListDataController.shared().editTeam(self.teamDetail.team.id, title: self.teamDetail.team.name, description: self.teamDetail.team.description, thumbnail: self.teamDetail.team.thumbnail, members: self.teamDetail.memberList, actions: teamActions) { [weak self] error in
            guard error == nil else {
                return
            }
            
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension EditActionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 72
        } else if indexPath.row == 1 {
            return 44
        } else {
            return 128
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InputCellId, for: indexPath) as! TeamInputCell
            cell.setup(field: "Description", content: self.actionDescription, required: true) { [weak self] text in
                self?.actionDescription = text
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ToggleCellId, for: indexPath) as! VotePreferencesToggleCell
            cell.setup(title: "Ongoing", isOn: false) { [weak self] isOn in
                self?.isOngoing = isOn
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.DateCellId, for: indexPath) as! ProposalDatePickerCell
            cell.setup(deadline: self.deadline) { [weak self] date in
                self?.deadline = date
            }
            return cell
        }
    }
    
}


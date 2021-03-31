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
    
    fileprivate var teamId: Int!
    fileprivate var originalAction: TeamAction?
    
    fileprivate var actionName: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var actionDescription: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var deadline: Date!
    fileprivate var isOngoing: Bool = false
    
    public static func create(teamId: Int, action: TeamAction? = nil) -> UIViewController {
        let sb = UIStoryboard(name: "EditAction", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        let eavc = vc.viewControllers.first! as! EditActionViewController
        eavc.setup(teamId: teamId, action: action)
        return vc
    }
    
    private func setup(teamId: Int, action: TeamAction?) {
        self.teamId = teamId
        self.originalAction = action
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let editingAction = self.originalAction {
            self.title = "Edit Action"
            self.actionName = editingAction.name
            self.actionDescription = editingAction.description
//            self.deadline = editingAction.deadline
            self.deadline = Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
        } else {
            self.refreshDoneButton()
            self.deadline = Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TeamInputCell {
            cell.makeTextFieldFirstResponder()
        }
    }
    
}

extension EditActionViewController {
    
    fileprivate func refreshDoneButton() {
        if let name = self.actionName, name.count > 0,
           let description = self.actionDescription, description.count > 0 {
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
        guard let name = self.actionName, name.count > 0,
              let description = self.actionDescription, description.count > 0 else {
            return
        }
        
        let newStatus: TeamActionStatus = self.isOngoing ? .ongoing : .pending
        
        self.blockView(message: "Submitting action...")
        TeamActionsDataController.shared(teamId: self.teamId).addAction(name: name, description: description, status: newStatus) { [weak self] error in
            self?.unblockView()
            
            guard error == nil else {
                return
            }
            
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func submitEditedAction(_ originalAction: TeamAction) {
        guard let name = self.actionName, name.count > 0,
              let description = self.actionDescription, description.count > 0 else {
            return
        }
        
        self.blockView(message: "Editing action...")
        TeamActionsDataController.shared(teamId: self.teamId).editAction(originalAction.id, name: name, description: description, status: originalAction.status) { [weak self] error in
            self?.unblockView()
            
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < 2 {
            return 72
        } else if indexPath.row == 2 {
            return 44
        } else {
            return 128
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InputCellId, for: indexPath) as! TeamInputCell
            cell.setup(field: "Action Name", content: self.actionName, required: true, updateBlock: { [weak self] text in
                self?.actionName = text
                return true
            }, submitBlock: { [weak self] text in
                self?.actionName = text
            })
            return cell
        } else if indexPath.row == 1 {
           let cell = tableView.dequeueReusableCell(withIdentifier: Self.InputCellId, for: indexPath) as! TeamInputCell
           cell.setup(field: "Description", content: self.actionDescription, required: true, updateBlock: { [weak self] text in
               self?.actionDescription = text
               return true
           }, submitBlock: { [weak self] text in
               self?.actionDescription = text
           })
           return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ToggleCellId, for: indexPath) as! VotePreferencesToggleCell
            cell.setup(title: "Ongoing", isOn: false) { [weak self] isOn in
                self?.isOngoing = isOn
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.DateCellId, for: indexPath) as! DatePickerCell
            cell.setup(title: "Deadline", deadline: self.deadline) { [weak self] date in
                self?.deadline = date
            }
            return cell
        }
    }
    
}


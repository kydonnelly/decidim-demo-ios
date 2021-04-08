//
//  EditActionViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class EditActionViewController: UIViewController, CustomTableController {
    
    fileprivate static let ToggleCellId = "ToggleCell"
    fileprivate static let ActionCellId = "ActionCell"
    fileprivate static let TitleCellId = "TitleCell"
    fileprivate static let BodyCellId = "BodyCell"
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
        
        self.autoInsetForKeyboard()
        
        self.tableView.register(UINib(nibName: "DatePickerCell", bundle: .main),
                                forCellReuseIdentifier: Self.DateCellId)
        self.tableView.register(UINib(nibName: "MultiLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.BodyCellId)
        self.tableView.register(UINib(nibName: "SingleLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.TitleCellId)
        
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
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SingleLineEntryCell {
            cell.makeTextFieldFirstResponder()
        }
    }
    
}

extension EditActionViewController {
    
    fileprivate var hasValidInput: Bool {
        guard let name = self.actionName, name.count > 0 else {
            return false
        }
        
        guard let description = self.actionDescription, description.count > 0 else {
            return false
        }
        
        return true
    }
    
    fileprivate func refreshDoneButton() {
        self.doneButtonItem.isEnabled = self.hasValidInput
        self.tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        } else if indexPath.row == 1 {
            return 112
        } else if indexPath.row == 2 {
            return 44
        } else if indexPath.row == 3 {
            return 128
        } else {
            return 72
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.TitleCellId, for: indexPath) as! SingleLineEntryCell
            cell.setup(field: "Action Name", content: self.actionName, required: true, updateBlock: { [weak self] text in
                self?.actionName = text
                return true
            })
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.BodyCellId, for: indexPath) as! MultiLineEntryCell
            cell.setup(field: "Description", content: self.actionDescription, updateBlock: { [weak self] text in
                self?.actionDescription = text
                return true
            })
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ToggleCellId, for: indexPath) as! VotePreferencesToggleCell
            cell.setup(title: "Ongoing", isOn: false) { [weak self] isOn in
                self?.isOngoing = isOn
            }
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.DateCellId, for: indexPath) as! DatePickerCell
            cell.setup(title: "Deadline", deadline: self.deadline) { [weak self] date in
                self?.deadline = date
            }
            return cell
        } else {
            let actionTitle = self.originalAction == nil ? "Create Action" : "Save Changes"
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ActionCellId, for: indexPath) as! SingleActionCell
            cell.setup(action: actionTitle, isEnabled: self.hasValidInput) { [weak self] sender in
                self?.didTapDoneButton(sender)
            }
            return cell
        }
    }
    
}


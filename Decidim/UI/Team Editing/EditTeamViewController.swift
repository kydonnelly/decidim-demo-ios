//
//  EditTeamViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import GiphyUISDK
import UIKit

class EditTeamViewController: UIViewController, CustomTableController {
    
    fileprivate static let ActionCellId = "ActionCell"
    fileprivate static let ImageCellId = "ImageCell"
    fileprivate static let TitleCellId = "TitleCell"
    fileprivate static let BodyCellId = "BodyCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButtonItem: UIBarButtonItem!
    
    fileprivate var originalTeam: TeamDetail?
    
    fileprivate var teamName: String? {
        didSet { refreshDoneButton() }
    }
    fileprivate var teamDescription: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var thumbnailMediaId: String?
    
    public static func create(team: TeamDetail? = nil) -> UIViewController {
        let sb = UIStoryboard(name: "EditTeam", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        let etvc = vc.viewControllers.first! as! EditTeamViewController
        etvc.setup(team: team)
        return vc
    }
    
    private func setup(team: TeamDetail?) {
        self.originalTeam = team
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "EditImageCell", bundle: .main),
                                forCellReuseIdentifier: Self.ImageCellId)
        self.tableView.register(UINib(nibName: "MultiLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.BodyCellId)
        self.tableView.register(UINib(nibName: "SingleLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.TitleCellId)
        
        if let editingTeam = self.originalTeam {
            self.title = "Edit Team"
            self.thumbnailMediaId = editingTeam.team.thumbnailUrl
            self.teamName = editingTeam.team.name
            self.teamDescription = editingTeam.team.description
        } else {
            self.refreshDoneButton()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SingleLineEntryCell {
            cell.makeTextFieldFirstResponder()
        }
    }
    
}

extension EditTeamViewController {
    
    fileprivate func refreshDoneButton() {
        if let name = self.teamName, name.count > 0,
           let description = self.teamDescription, description.count > 0 {
            self.doneButtonItem.isEnabled = true
        } else {
            self.doneButtonItem.isEnabled = false
        }
    }
    
}

extension EditTeamViewController {
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        if let editingTeamId = self.originalTeam?.team.id {
            self.submitEditedTeam(id: editingTeamId)
        } else {
            self.submitNewTeam()
        }
    }
    
    private func submitNewTeam() {
        guard let name = self.teamName, let description = self.teamDescription,
              let memberId = MyProfileController.shared.myProfileId else {
            return
        }
        
        self.blockView(message: "Creating team...")
        TeamListDataController.shared().addTeam(title: name, description: description, thumbnailUrl: self.thumbnailMediaId, members: [memberId: .joined]) { [weak self] error in
            self?.unblockView()
            
            if error == nil {
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func submitEditedTeam(id: Int) {
        guard let name = self.teamName, let description = self.teamDescription else {
            return
        }
        
        self.blockView(message: "Editing team...")
        TeamListDataController.shared().editTeam(id, title: name, description: description, thumbnailUrl: self.thumbnailMediaId) { [weak self] error in
            self?.unblockView()
            
            if error == nil {
                self?.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension EditTeamViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            return 120
        } else {
            return 72
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.TitleCellId, for: indexPath) as! SingleLineEntryCell
            cell.setup(field: "Title", content: self.teamName, required: true, updateBlock: { [weak self] text in
                self?.teamName = text
                return true
            }, submitBlock: { [weak self] text in
                self?.teamName = text
            })
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ImageCellId, for: indexPath) as! EditImageCell
            cell.setup(thumbnailUrl: self.thumbnailMediaId) { [weak self] in
                self?.showImagePicker(indexPath: indexPath)
            }
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.BodyCellId, for: indexPath) as! MultiLineEntryCell
            cell.setup(field: "Description", content: self.teamDescription, updateBlock: { [weak self] text in
                self?.teamDescription = text
                return true
            }, submitBlock: { [weak self] text in
                self?.teamDescription = text
            })
            return cell
        } else {
            let actionTitle = self.originalTeam == nil ? "Create Team" : "Save Changes"
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ActionCellId, for: indexPath) as! SingleActionCell
            cell.setup(action: actionTitle) { [weak self] sender in
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

extension EditTeamViewController: GiphyDelegate {
    
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

//
//  EditTeamViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class EditTeamViewController: UIViewController, CustomTableController {
    
    fileprivate static let InputCellId = "InputCell"
    fileprivate static let ImageCellId = "ImageCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButtonItem: UIBarButtonItem!
    
    fileprivate var originalTeam: TeamDetail?
    
    fileprivate var teamName: String? {
        didSet { refreshDoneButton() }
    }
    fileprivate var teamDescription: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var thumbnail: UIImage?
    
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
        
        if let editingTeam = self.originalTeam {
            self.title = "Edit Team"
            self.thumbnail = editingTeam.team.thumbnail
            self.teamName = editingTeam.team.name
            self.teamDescription = editingTeam.team.description
        } else {
            self.refreshDoneButton()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TeamInputCell {
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
        self.navigationController?.dismiss(animated: true, completion: nil)
        
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
        
        TeamListDataController.shared().addTeam(title: name, description: description, thumbnail: self.thumbnail, members: [memberId: .joined]) { _ in }
    }
    
    private func submitEditedTeam(id: Int) {
        guard let name = self.teamName, let description = self.teamDescription else {
            return
        }
        
        TeamListDataController.shared().editTeam(id, title: name, description: description, thumbnail: self.thumbnail, members: self.originalTeam!.memberList, actions: self.originalTeam!.actionList, delegates: self.originalTeam!.delegationList) { _ in }
    }
    
}

extension EditTeamViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 {
            return 50
        } else {
            return 72
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InputCellId, for: indexPath) as! TeamInputCell
            cell.setup(field: "Title", content: self.teamName, required: true, updateBlock: { [weak self] text in
                self?.teamName = text
                return true
            }, submitBlock: { [weak self] text in
                self?.teamName = text
            })
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InputCellId, for: indexPath) as! TeamInputCell
            cell.setup(field: "Description", content: self.teamDescription, required: true, updateBlock: { [weak self] text in
                self?.teamDescription = text
                return true
            }, submitBlock: { [weak self] text in
                self?.teamDescription = text
            })
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ImageCellId, for: indexPath) as! TeamImageCell
            cell.setup(thumbnail: self.thumbnail) { [weak self] in
                self?.showImagePicker(indexPath: indexPath)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            self.showImagePicker(indexPath: indexPath)
        }
    }
    
}

extension EditTeamViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate func showImagePicker(indexPath: IndexPath) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            imagePicker.mediaTypes = mediaTypes
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = self.mediaImage(info: info) {
            self.thumbnail = image
        }
        
        picker.dismiss(animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func mediaImage(info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[.editedImage] as? UIImage {
            return image
        }
        
        if let image = info[.originalImage] as? UIImage {
            return image
        }
        
        return nil
    }
    
}

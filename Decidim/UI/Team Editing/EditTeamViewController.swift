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
    fileprivate static let ToggleCellId = "ToggleCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButtonItem: UIBarButtonItem!
    
    fileprivate var originalTeam: TeamDetail?
    fileprivate var isPrivate: Bool = false
    
    fileprivate var teamName: String? {
        didSet { refreshDoneButton() }
    }
    fileprivate var teamDescription: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var thumbnailURL: String?
    
    public static func create(team: TeamDetail? = nil) -> UIViewController {
        let sb = UIStoryboard(name: "EditTeam", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        let etvc = vc.viewControllers.first! as! EditTeamViewController
        etvc.setup(team: team)
        return vc
    }
    
    private func setup(team: TeamDetail?) {
        self.originalTeam = team
        if let origTeam = team {
            self.isPrivate = origTeam.team.isPrivate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.autoInsetForKeyboard()
        
        self.tableView.register(UINib(nibName: "EditImageCell",
            bundle: .main),
                                forCellReuseIdentifier: Self.ImageCellId)
        self.tableView.register(UINib(nibName: "MultiLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.BodyCellId)
        self.tableView.register(UINib(nibName: "ToggleCell",
            bundle: .main),
                                forCellReuseIdentifier: Self.ToggleCellId)
        self.tableView.register(UINib(nibName: "SingleLineEntryCell", bundle: .main),
                                forCellReuseIdentifier: Self.TitleCellId)
        
        if let editingTeam = self.originalTeam {
            self.title = "Edit Group"
            self.thumbnailURL = editingTeam.team.thumbnailUrl
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
    
    fileprivate var hasValidInput: Bool {
        guard let name = self.teamName, name.count > 0 else {
            return false
        }
        
        guard let description = self.teamDescription, description.count > 0 else {
            return false
        }
        
        return true
    }
    
    fileprivate func refreshDoneButton() {
        self.doneButtonItem.isEnabled = self.hasValidInput
        self.tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
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
        
        self.blockView(message: "Creating group...")
        TeamListDataController.shared().addTeam(title: name, description: description, isPrivate: isPrivate, thumbnailUrl: self.thumbnailURL, members: [memberId: .active]) { [weak self] error in
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
        
        self.blockView(message: "Editing group...")
        TeamListDataController.shared().editTeam(id, title: name, description: description, isPrivate: isPrivate, thumbnailUrl: self.thumbnailURL) { [weak self] error in
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        } else if indexPath.row == 1 {
            return 112
        } else if indexPath.row == 2 {
            return 120
        } else if indexPath.row == 3{
            return 44
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
            })
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ImageCellId, for: indexPath) as! EditImageCell
            cell.setup(thumbnailUrl: self.thumbnailURL) { [weak self] gif in
                if gif {
                    self?.showGifPicker()
                } else {
                    self?.showImagePicker()
                }
            }
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.BodyCellId, for: indexPath) as! MultiLineEntryCell
            cell.setup(field: "Description", content: self.teamDescription, updateBlock: { [weak self] text in
                self?.teamDescription = text
                return true
            })
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ToggleCellId, for: indexPath) as! ToggleCell
            cell.setup(title: "Private Group", isOn: self.isPrivate) {
                [weak self] isOn in
                self?.isPrivate = isOn
            }
            return cell
        } else {
            let actionTitle = self.originalTeam == nil ? "Create Group" : "Save Changes"
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ActionCellId, for: indexPath) as! SingleActionCell
            cell.setup(action: actionTitle, isEnabled: self.hasValidInput) { [weak self] sender in
                self?.didTapDoneButton(sender)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            self.showImagePicker()
        }
    }
    
}

extension EditTeamViewController: GiphyDelegate {
    
    fileprivate func showGifPicker() {
        let imagePicker = GiphyManager.shared.giphyViewController(delegate: self)
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        self.thumbnailURL = media.id
        
        giphyViewController.dismiss(animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func didDismiss(controller: GiphyViewController?) {
        self.tableView.reloadData()
    }
    
}

extension EditTeamViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate func showImagePicker() {
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
        guard let image = info.mediaImage, let localPath = info.imageURL else {
            return
        }
        
        AWSManager.shared.uploadImage(image, path: localPath) { [weak self] serverURL in
            guard let url = serverURL else {
                return
            }
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.thumbnailURL = url.absoluteString
                self.tableView.reloadData()
            }
        }
        
        picker.dismiss(animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
}

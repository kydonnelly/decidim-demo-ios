//
//  SettingsViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import GiphyUISDK
import UIKit

class SettingsViewController: UIViewController, CustomTableController {
    
    @IBOutlet var tableView: UITableView!
    
    private var profileDataController: ProfileInfoDataController!
    
    fileprivate enum State {
        case loading
        case noProfile
        case profile(ProfileInfo)
    }
    
    static let loadingCellId = "LoadingCell"
    static let actionCellId = "ActionCell"
    static let appInfoCellId = "AppInfoCell"
    static let usernameCellId = "UsernameCell"
    static let passwordCellId = "PasswordCell"
    static let votingCellId = "VotingCell"
    
    public static func create() -> SettingsViewController {
        let sb = UIStoryboard(name: "Settings", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! SettingsViewController
        return nvc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh()
    }
    
    fileprivate func refresh() {
        defer {
            self.tableView.reloadData()
        }
        
        guard MyProfileController.shared.isRegistered else {
            return
        }
        
        self.profileDataController = ProfileInfoDataController.shared()
        self.profileDataController.refresh { [weak self] dc in
            self?.tableView.reloadData()
        }
    }
    
    fileprivate var state: State {
        guard let profileId = MyProfileController.shared.myProfileId else {
            return .noProfile
        }
        guard let profiles = self.profileDataController?.data as? [ProfileInfo] else {
            return .loading
        }
        guard let myInfo = profiles.first(where: { $0.profileId == profileId }) else {
            guard let localHandle: String = MyProfileController.load(key: .username) else {
                return .noProfile
            }
            
            return .profile(ProfileInfo(profileId: profileId, handle: localHandle, thumbnailUrl: nil))
        }
        
        return .profile(myInfo)
    }
    
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private var numberOfRows: Int {
        switch self.state {
        case .loading:
            return 1
        case .noProfile:
            return 1
        case .profile:
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.state {
        case .loading:
            return 44
        case .noProfile:
            return 72
        case .profile:
            break
        }
        
        if indexPath.row == 0 {
            return 76
        } else if indexPath.row >= 1 && indexPath.row < 4 {
            return 44
        } else if indexPath.row == 4 {
            return 72
        } else {
            preconditionFailure("Unexpected indexPath in ProfileViewController")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var profileInfo: ProfileInfo!
        
        switch self.state {
        case .loading:
            return tableView.dequeueReusableCell(withIdentifier: Self.loadingCellId, for: indexPath)
        case .noProfile:
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.actionCellId, for: indexPath) as! SettingsActionCell
            cell.setup(title: "Register Account") { [weak self] in
                let registerVC = RegistrationViewController.create()
                registerVC.modalPresentationStyle = .fullScreen
                self?.navigationController?.present(registerVC, animated: true, completion: nil)
            }
            return cell
        case let .profile(info):
            profileInfo = info
            break
        }
        
        if indexPath.row == 0 {
            let nameCell = tableView.dequeueReusableCell(withIdentifier: Self.usernameCellId, for: indexPath) as! SettingsProfileCell
            nameCell.setup(profile: profileInfo) { [weak self] in
                self?.showImagePicker()
            }
            return nameCell
        } else if indexPath.row == 1 {
            let passwordCell = tableView.dequeueReusableCell(withIdentifier: Self.passwordCellId, for: indexPath) as! SettingsPreferencesCell
            passwordCell.setup(title: "Password", detail: "Change")
            return passwordCell
        } else if indexPath.row == 2 {
            let votingCell = tableView.dequeueReusableCell(withIdentifier: Self.votingCellId, for: indexPath) as! SettingsPreferencesCell
            votingCell.setup(title: "Voting Preferences", detail: "Update")
            return votingCell
        } else if indexPath.row == 3 {
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            let appInfoCell = tableView.dequeueReusableCell(withIdentifier: Self.appInfoCellId, for: indexPath) as! SettingsPreferencesCell
            appInfoCell.setup(title: "App Version", detail: appVersion ?? "Unknown")
            return appInfoCell
        } else if indexPath.row == 4 {
            let actionCell = tableView.dequeueReusableCell(withIdentifier: Self.actionCellId, for: indexPath) as! SettingsActionCell
            actionCell.setup(title: "Sign Out") { [weak self] in
                MyProfileController.shared.signOut()
                let registerVC = RegistrationViewController.create()
                registerVC.modalPresentationStyle = .fullScreen
                self?.navigationController?.present(registerVC, animated: true, completion: nil)
            }
            return actionCell
        } else {
            preconditionFailure("Unexpected indexPath in ProfileViewController")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch self.state {
        case .loading:
            return
        case .noProfile:
            return
        case .profile:
            break
        }
        
        if indexPath.row == 0 {
            self.showImagePicker()
        } else if indexPath.row == 1 {
            let passwordVC = ChangePasswordViewController.create()
            self.navigationController?.pushViewController(passwordVC, animated: true)
        } else if indexPath.row == 2 {
            let preferencesVC = VotePreferencesViewController.create()
            self.navigationController?.pushViewController(preferencesVC, animated: true)
        }
    }
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.row == 0 else { return nil }
        guard case .profile = self.state else { return nil }
        
        let provider: UIContextMenuActionProvider = { [weak self] suggestedActions in
            UIMenu(title: "", identifier: UIMenu.Identifier("com.cooperative4thecommunity.Decidim.settingsTable"), children: [
                UIAction(title: "Image", identifier: UIAction.Identifier("com.cooperative4thecommunity.Decidim.settingsTableEditImage")) { [weak self] action in
                    self?.showImagePicker()
                },
                UIAction(title: "GIF", identifier: UIAction.Identifier("com.cooperative4thecommunity.Decidim.settingsTableEditGif")) { [weak self] action in
                    self?.showGifPicker()
                }
            ])
        }
        
        return UIContextMenuConfiguration(identifier: "com.cooperative4thecommunity.Decidim.choosePhotoButton" as NSCopying, previewProvider: nil, actionProvider: provider)
    }
    
}

extension SettingsViewController: GiphyDelegate {
    
    fileprivate func showGifPicker() {
        let imagePicker = GiphyManager.shared.giphyViewController(delegate: self)
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        giphyViewController.dismiss(animated: true, completion: nil)
        
        self.update(thumbnailUrl: media.id)
    }
    
    func didDismiss(controller: GiphyViewController?) {
        self.tableView.reloadData()
    }
    
    fileprivate func update(thumbnailUrl: String) {
        guard case let .profile(info) = self.state else {
            return
        }
        
        ProfileInfoDataController.shared().editProfile(info.profileId, name: info.handle, thumbnailUrl: thumbnailUrl) { [weak self] _ in
            self?.refresh()
        }
    }
    
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                self.update(thumbnailUrl: url.absoluteString)
            }
        }
        
        picker.dismiss(animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
}

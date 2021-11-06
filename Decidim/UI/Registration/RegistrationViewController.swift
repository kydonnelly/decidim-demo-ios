//
//  RegistrationViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/5/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import GiphyUISDK
import UIKit

class RegistrationViewController: UIViewController, CustomScrollController {
    
    enum RegistrationType: Int {
        case newUser
        case existingUser
    }
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var optionsBar: OptionsBar!
    
    @IBOutlet var photoImageView: ThumbnailView!
    @IBOutlet var choosePhotoButton: ChoosePhotoButton!
    @IBOutlet var photoContainerConstraint: NSLayoutConstraint!
    
    private var thumbnailUrl: String?
    private var currentMode: RegistrationType = .newUser {
        didSet {
            self.refreshDisplayType()
        }
    }
    
    public static func create() -> RegistrationViewController {
        let sb = UIStoryboard(name: "Registration", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! RegistrationViewController
        return nvc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.autoInsetForKeyboard()
        
        self.refreshDisplayType()
        self.refreshSubmitButton()
        
        self.choosePhotoButton.setup { [weak self] asGif in
            if asGif {
                self?.showGifPicker()
            } else {
                self?.showImagePicker()
            }
        }
        
        self.optionsBar.setup(options: ["Sign Up", "Log In"], selectedIndex: self.currentMode.rawValue) { index in
            guard let mode = RegistrationType(rawValue: index) else { return }
            self.currentMode = mode
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.usernameField.becomeFirstResponder()
    }
    
}

extension RegistrationViewController {
    
    private func hasValidInput(editingField: UITextField? = nil, editedText: String? = nil) -> Bool {
        let usernameText = editingField == self.usernameField ? editedText : self.usernameField.text
        let passwordText = editingField == self.passwordField ? editedText : self.passwordField.text
        
        guard let username = usernameText, let password = passwordText else {
            return false
        }
        
        if self.currentMode == .newUser, self.thumbnailUrl == nil {
            return false
        }
        
        return username.count > 2 && password.count > 2
    }
    
    fileprivate func refreshSubmitButton(editingField: UITextField? = nil, editedText: String? = nil) {
        let hasValidInput = self.hasValidInput(editingField: editingField, editedText: editedText)
        
        self.submitButton.isEnabled = hasValidInput
        self.submitButton.backgroundColor = hasValidInput ? .action : .lightGray
    }
    
    fileprivate func refreshDisplayType() {
        switch self.currentMode {
        case .newUser:
            self.submitButton.setTitle("Create Account", for: .normal)
            self.photoContainerConstraint.constant = 72
        case .existingUser:
            self.submitButton.setTitle("Log In", for: .normal)
            self.photoContainerConstraint.constant = 0
        }
        
        self.usernameField.text = ""
        self.passwordField.text = ""
        self.refreshSubmitButton()
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton?) {
        self.showImagePicker()
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton?) {
        guard self.hasValidInput() else {
            return
        }
        
        guard let username = usernameField.text, let password = passwordField.text else {
            return
        }
        
        let updateBlock: MyProfileController.UpdateBlock = { [weak self] error in
            guard let self = self else { return }
            self.unblockView()
            
            if error == nil {
                ProfileInfoDataController.shared().invalidate()
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Something went wrong.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak self] _ in
                    self?.usernameField.becomeFirstResponder()
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        switch self.currentMode {
        case .newUser:
            self.blockView(message: "Creating Account...")
            MyProfileController.shared.register(username: username, password: password, thumbnail: self.thumbnailUrl, completion: updateBlock)
        case .existingUser:
            self.blockView(message: "Logging In...")
            MyProfileController.shared.signIn(username: username, password: password, completion: updateBlock)
        }
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let range = Range(range, in: text) else {
            return true
        }
        
        let updatedString = text.replacingCharacters(in: range, with: string)
        self.refreshSubmitButton(editingField: textField, editedText: updatedString)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.hasValidInput() && textField == self.passwordField {
            self.submitButtonPressed(nil)
            return true
        }
        
        if textField == self.usernameField {
            self.passwordField.becomeFirstResponder()
        } else if textField == self.passwordField {
            self.usernameField.becomeFirstResponder()
        }
        
        return true
    }
    
}

extension RegistrationViewController: GiphyDelegate {
    
    fileprivate func showGifPicker() {
        let imagePicker = GiphyManager.shared.giphyViewController(delegate: self)
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        self.thumbnailUrl = media.id
        
        giphyViewController.dismiss(animated: true) { [weak self] in
            self?.photoImageView.setThumbnail(url: media.id)
            self?.refreshSubmitButton()
        }
    }
    
    func didDismiss(controller: GiphyViewController?) {
        
    }
    
}

extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
                self.thumbnailUrl = url.absoluteString
                self.photoImageView.setThumbnail(url: self.thumbnailUrl)
                self.refreshSubmitButton()
            }
        }
        
        picker.dismiss(animated: true)
    }
    
}

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
    
    typealias CompletionBlock = (RegistrationType) -> Void
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    private var onCompletion: CompletionBlock?
    
    public static func create(completion: CompletionBlock? = nil) -> UIViewController {
        let sb = UIStoryboard(name: "Registration", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! UINavigationController
        let vc = nvc.viewControllers.first as! RegistrationViewController
        vc.setup(completion: completion)
        return nvc
    }
    
    private func setup(completion: CompletionBlock?) {
        self.onCompletion = completion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.autoInsetForKeyboard()
        
        self.refreshDisplayType()
        self.refreshSubmitButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.usernameField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

extension RegistrationViewController {
    
    private func hasValidInput(editingField: UITextField? = nil, editedText: String? = nil) -> Bool {
        let usernameText = editingField == self.usernameField ? editedText : self.usernameField.text
        let passwordText = editingField == self.passwordField ? editedText : self.passwordField.text
        
        guard let username = usernameText, let password = passwordText else {
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
        self.usernameField.text = ""
        self.passwordField.text = ""
        self.refreshSubmitButton()
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton?) {
        let vc = ForgotPasswordViewController.create()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func createAccountButtonPressed(_ sender: UIButton?) {
        let vc = CreateAccountViewController.create { [weak self] in
            self?.dismiss(type: .newUser)
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
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
                self.dismiss(type: .existingUser)
            } else {
                let alert = UIAlertController(title: "Error", message: "Something went wrong.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak self] _ in
                    self?.usernameField.becomeFirstResponder()
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        self.blockView(message: "Logging In...")
        MyProfileController.shared.signIn(username: username, password: password, completion: updateBlock)
    }
    
    private func dismiss(type: RegistrationType) {
        self.onCompletion?(type)
        self.navigationController?.dismiss(animated: true, completion: nil)
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

//
//  ChangePasswordViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet var currentPasswordField: UITextField!
    @IBOutlet var newPasswordField: UITextField!
    @IBOutlet var confirmedPasswordField: UITextField!
    
    @IBOutlet var submitButton: UIButton!
    
    public static func create() -> ChangePasswordViewController {
        let sb = UIStoryboard(name: "ChangePassword", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! ChangePasswordViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Change Password"
        
        self.refreshSubmitButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.currentPasswordField.becomeFirstResponder()
    }
    
}

extension ChangePasswordViewController {
    
    private func hasValidInput(editingField: UITextField? = nil, editedText: String? = nil) -> Bool {
        let currentPasswordText = editingField == self.currentPasswordField ? editedText : self.currentPasswordField.text
        let newPasswordText = editingField == self.newPasswordField ? editedText : self.newPasswordField.text
        let confirmedPasswordText = editingField == self.confirmedPasswordField ? editedText : self.confirmedPasswordField.text
        
        guard let currentPassword = currentPasswordText else {
            return false
        }
        
        guard let newPassword = newPasswordText, let confirmedPassword = confirmedPasswordText else {
            return false
        }
        
        return currentPassword.count > 2 && newPassword.count > 2 && confirmedPassword.count > 2
    }
    
    fileprivate func refreshSubmitButton(editingField: UITextField? = nil, editedText: String? = nil) {
        let hasValidInput = self.hasValidInput(editingField: editingField, editedText: editedText)
        
        self.submitButton.isEnabled = hasValidInput
        self.submitButton.backgroundColor = hasValidInput ? .action : .lightGray
    }
    
    fileprivate func clearField(_ textField: UITextField) {
        textField.text = ""
        self.refreshSubmitButton()
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton?) {
        guard let currentPassword = self.currentPasswordField.text, currentPassword == MyProfileController.load(key: .password) else {
            let alert = UIAlertController(title: "Error", message: "Incorrect current password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.clearField(self.currentPasswordField)
                self.currentPasswordField.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let newPassword = self.newPasswordField.text,
              let confirmedPassword = self.confirmedPasswordField.text,
              newPassword == confirmedPassword else {
            let alert = UIAlertController(title: "Error", message: "New password does not match.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.clearField(self.confirmedPasswordField)
                self.confirmedPasswordField.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
                
            return
        }
        
        // TODO: Success
        let alert = UIAlertController(title: "Error", message: "Could not update password.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ChangePasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let range = Range(range, in: text) else {
            return true
        }
        
        let updatedString = text.replacingCharacters(in: range, with: string)
        self.refreshSubmitButton(editingField: textField, editedText: updatedString)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.hasValidInput() && textField == self.confirmedPasswordField {
            self.submitButtonTapped(nil)
            return true
        }
        
        if textField == self.currentPasswordField {
            self.newPasswordField.becomeFirstResponder()
        } else if textField == self.newPasswordField {
            self.confirmedPasswordField.becomeFirstResponder()
        } else if textField == self.confirmedPasswordField {
            self.currentPasswordField.becomeFirstResponder()
        }
        
        return true
    }
    
}

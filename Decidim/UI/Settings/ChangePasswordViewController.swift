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
    
    private var hasValidInput: Bool {
        guard let currentPassword = self.currentPasswordField.text else {
            return false
        }
        
        guard let newPassword = self.newPasswordField.text, let confirmedPassword = self.confirmedPasswordField.text else {
            return false
        }
        
        return currentPassword.count > 2 && newPassword.count > 2 && confirmedPassword.count > 2
    }
    
    fileprivate func refreshSubmitButton() {
        self.submitButton.isEnabled = self.hasValidInput
        self.submitButton.backgroundColor = self.hasValidInput ? .action : .lightGray
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton?) {
        guard let currentPassword = self.currentPasswordField.text, currentPassword == MyProfileController.load(key: .password) else {
            let alert = UIAlertController(title: "Error", message: "Incorrect current password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
                self?.currentPasswordField.text = ""
                self?.currentPasswordField.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let newPassword = self.newPasswordField.text,
              let confirmedPassword = self.confirmedPasswordField.text,
              newPassword == confirmedPassword else {
            let alert = UIAlertController(title: "Error", message: "New password does not match.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
                self?.confirmedPasswordField.text = ""
                self?.confirmedPasswordField.becomeFirstResponder()
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
        self.refreshSubmitButton()
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.hasValidInput {
            self.submitButtonTapped(nil)
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

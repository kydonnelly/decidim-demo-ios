//
//  RegistrationViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/5/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    enum RegistrationType {
        case newUser
        case existingUser
    }
    
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var registrationModeButton: UIButton!
    
    private var currentMode: RegistrationType = .existingUser
    
    public static func create() -> RegistrationViewController {
        let sb = UIStoryboard(name: "Registration", bundle: .main)
        let nvc = sb.instantiateInitialViewController() as! RegistrationViewController
        return nvc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshDisplayType()
        self.refreshSubmitButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.usernameField.becomeFirstResponder()
    }
    
}

extension RegistrationViewController {
    
    private var hasValidInput: Bool {
        guard let username = usernameField.text, let password = passwordField.text else {
            return false
        }
        
        return username.count > 2 && password.count > 2
    }
    
    fileprivate func refreshSubmitButton() {
        self.submitButton.isEnabled = self.hasValidInput
        self.submitButton.backgroundColor = self.hasValidInput ? .action : .lightGray
    }
    
    fileprivate func refreshDisplayType() {
        switch self.currentMode {
        case .newUser:
            self.submitButton.setTitle("Create Account", for: .normal)
            self.registrationModeButton.setTitle("Log In", for: .normal)
        case .existingUser:
            self.submitButton.setTitle("Log In", for: .normal)
            self.registrationModeButton.setTitle("Sign Up", for: .normal)
        }
        
        self.usernameField.text = ""
        self.passwordField.text = ""
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton?) {
        guard self.hasValidInput else {
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
            MyProfileController.shared.register(username: username, password: password, completion: updateBlock)
        case .existingUser:
            self.blockView(message: "Logging In...")
            MyProfileController.shared.signIn(username: username, password: password, completion: updateBlock)
        }
    }
    
    @IBAction func switchModeButtonPressed(_ sender: UIButton) {
        switch self.currentMode {
        case .newUser:
            self.currentMode = .existingUser
        case .existingUser:
            self.currentMode = .newUser
        }
        
        self.refreshDisplayType()
    }
    
}

extension RegistrationViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.refreshSubmitButton()
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameField {
            self.passwordField.becomeFirstResponder()
        } else if textField == self.passwordField {
            self.submitButtonPressed(nil)
        }
        
        return true
    }
    
}

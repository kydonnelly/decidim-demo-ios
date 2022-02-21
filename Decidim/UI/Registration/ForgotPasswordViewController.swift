//
//  ForgotPasswordViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/5/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import GiphyUISDK
import UIKit

class ForgotPasswordViewController: UIViewController, CustomScrollController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    private let emailDetector: NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    
    public static func create() -> ForgotPasswordViewController {
        let sb = UIStoryboard(name: "ForgotPassword", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! ForgotPasswordViewController
        vc.setup()
        return vc
    }
    
    private func setup() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.autoInsetForKeyboard()
        
        self.refreshDisplayType()
        self.refreshSubmitButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.emailField.becomeFirstResponder()
    }
    
}

extension ForgotPasswordViewController {
    
    private func hasValidInput(editingField: UITextField? = nil, editedText: String? = nil) -> Bool {
        guard let emailString = editingField === self.emailField ? editedText : self.emailField.text else {
            return false
        }
        
        let range = NSRange(location: 0, length: emailString.count)
        guard let matches = self.emailDetector?.matches(in: emailString, options: [], range: range) else {
            return false
        }
        
        let emailMatches = matches.filter {
            $0.range == range && $0.url?.scheme == "mailto"
        }
        
        return emailMatches.count == 1
    }
    
    fileprivate func refreshSubmitButton(editingField: UITextField? = nil, editedText: String? = nil) {
        let hasValidInput = self.hasValidInput(editingField: editingField, editedText: editedText)
        
        self.submitButton.isEnabled = hasValidInput
        self.submitButton.backgroundColor = hasValidInput ? .action : .lightGray
    }
    
    fileprivate func refreshDisplayType() {
        self.emailField.text = ""
        self.refreshSubmitButton()
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton?) {
        guard self.hasValidInput() else {
            return
        }
        
        guard let email = self.emailField.text else {
            return
        }
        
        let completion: (Error?) -> Void = { [weak self] error in
            guard let self = self else { return }
            self.unblockView()
            
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            } else {
                let alert = UIAlertController(title: "Error", message: "Something went wrong.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak self] _ in
                    self?.emailField.becomeFirstResponder()
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        self.blockView(message: "Submitting...")
        PasswordController.requestPasswordReset(email: email, completion: completion)
    }
    
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let range = Range(range, in: text) else {
            return true
        }
        
        let updatedString = text.replacingCharacters(in: range, with: string)
        self.refreshSubmitButton(editingField: textField, editedText: updatedString)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.hasValidInput() {
            self.submitButtonPressed(nil)
        }
        
        return true
    }
    
}

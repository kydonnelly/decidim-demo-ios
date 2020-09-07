//
//  ChangePasswordCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class ChangePasswordCell: UITableViewCell {
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmField: UITextField!
    @IBOutlet var submitButton: UIButton!
    
    @IBAction func tappedSubmitButton(sender: UIButton) {
        
    }
    
}

extension ChangePasswordCell: UITextFieldDelegate {
    
}

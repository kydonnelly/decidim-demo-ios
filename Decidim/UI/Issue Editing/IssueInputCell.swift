//
//  IssueInputCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueInputCell: CustomTableViewCell {
    
    typealias IssueInputUpdateBlock = (String) -> Bool
    typealias IssueInputSubmitBlock = (String) -> Void
    
    @IBOutlet var inputField: UITextField!
    
    private var onUpdate: IssueInputUpdateBlock?
    private var onSubmit: IssueInputSubmitBlock?
    
    public func setup(field: String, content: String?, required: Bool, characterLimit: Int? = nil, updateBlock: IssueInputUpdateBlock? = nil, submitBlock: IssueInputSubmitBlock?) {
        var placeholder = field
        if required {
            placeholder.append(" (Required)")
        }
        
        self.inputField.placeholder = placeholder
        self.inputField.text = content
        
        self.onUpdate = updateBlock
        self.onSubmit = submitBlock
    }
    
}

extension IssueInputCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let onUpdate = self.onUpdate, let text = textField.text, let range = Range(range, in: text) {
            let updatedString = text.replacingCharacters(in: range, with: string)
            return onUpdate(updatedString)
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let onSubmit = self.onSubmit, let text = textField.text {
            onSubmit(text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
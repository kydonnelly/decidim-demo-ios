//
//  SingleLineEntryCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/30/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class SingleLineEntryCell: CustomTableViewCell {
    
    typealias UpdateBlock = (String) -> Bool
    typealias SubmitBlock = (String) -> Void
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var inputField: UITextField!
    
    private var onUpdate: UpdateBlock?
    private var onSubmit: SubmitBlock?
    
    public func setup(field: String, content: String?, required: Bool, characterLimit: Int? = nil, updateBlock: UpdateBlock? = nil, submitBlock: SubmitBlock?) {
        var placeholder = field
        if required {
            placeholder.append(" (Required)")
        }
        
        self.inputField.placeholder = placeholder
        self.inputField.text = content
        
        self.titleLabel.text = field
        
        self.onUpdate = updateBlock
        self.onSubmit = submitBlock
    }
    
}

extension SingleLineEntryCell: UITextFieldDelegate {
    
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


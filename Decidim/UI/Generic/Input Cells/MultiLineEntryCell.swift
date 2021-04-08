//
//  MultiLineEntryCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/30/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class MultiLineEntryCell: CustomTableViewCell {
    
    typealias UpdateBlock = (String) -> Bool
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var inputField: UITextView!
    
    private var onUpdate: UpdateBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var insets = self.inputField.textContainerInset
        insets.left += 8
        insets.right += 8
        self.inputField.textContainerInset = insets
    }
    
    public func setup(field: String, content: String?, updateBlock: UpdateBlock?) {
        self.titleLabel.text = field
        self.inputField.text = content
        
        self.onUpdate = updateBlock
    }
    
}

extension MultiLineEntryCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let onUpdate = self.onUpdate, let currentText = textView.text, let range = Range(range, in: currentText) {
            let updatedString = currentText.replacingCharacters(in: range, with: text)
            return onUpdate(updatedString)
        } else {
            return true
        }
    }
    
}


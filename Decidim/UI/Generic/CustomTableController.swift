//
//  CustomTableController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/2/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

protocol CustomTableController: UIViewController {
    var tableView: UITableView! { get }
}

extension CustomTableController {
    
    @discardableResult
    func scrollToTop() -> Bool {
        let top = -1 * self.tableView.adjustedContentInset.top
        if self.tableView.contentOffset.y >= 24 + top {
            self.tableView.setContentOffset(CGPoint(x: 0, y: top), animated: true)
            return true
        } else {
            return false
        }
    }
    
}

extension CustomTableController {
    
    func autoInsetForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIView.keyboardWillChangeFrameNotification, object: nil)
    }
    
}

extension UIViewController {
    
    @objc public func keyboardWillChangeFrame(_ notification: Notification) {
        guard let vc = self as? CustomTableController else {
            return
        }
        
        guard let keyboardFrame = notification.userInfo?[UIView.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        var insets = vc.tableView.contentInset
        insets.bottom = keyboardFrame.height
        vc.tableView.contentInset = insets
    }
    
}

//
//  CustomTableViewCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/9/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

/// General purpose cell that provides consistent selection UI throughout the app
class CustomTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = UIColor.primaryDark.withAlphaComponent(0.125)
        self.selectedBackgroundView = view
    }
    
}

//extension UITableViewCell {
//
//    private func swizzle_selectionColor(_ color: UIColor) {
//        let c: AnyClass = UITableViewCell.self
//        let s = #selector(getter: UITableViewCell.selectedBackgroundView)
//
//        let block: @convention(block) (AnyObject, va_list) -> UIView? = { blockSelf, argp -> UIView? in
//            let selectedView = UIView()
//            selectedView.backgroundColor = color
//            return selectedView
//        }
//
//        guard let method = class_getInstanceMethod(c, s) else {
//            return
//        }
//
//        let types = method_getTypeEncoding(method)
//        let originalImp = class_replaceMethod(c, s, imp_implementationWithBlock(block), types)
//        assert(originalImp != nil)
//    }
//
//}

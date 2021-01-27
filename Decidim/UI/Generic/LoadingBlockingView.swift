//
//  LoadingBlockingView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 1/27/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class LoadingBlockingView: UIView {
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    public func setup(message: String) {
        self.messageLabel.text = message
        self.indicator.startAnimating()
    }
    
}

extension UIView {
    
    public func block(message: String) {
        let nib = UINib(nibName: "LoadingBlockingView", bundle: .main)
        guard let view = nib.instantiate(withOwner: nil).first as? LoadingBlockingView else {
            return
        }
        
        view.setup(message: message)
        self.block(with: view)
    }
    
}

extension UIViewController {
    
    public func blockView(message: String) {
        self.view.block(message: message)
    }
    
}

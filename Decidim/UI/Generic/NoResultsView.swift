//
//  NoResultsView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class NoResultsView: UIView {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    
    public func setup(message: String, imageIcon: VotionIcon) {
        self.imageView.icon = imageIcon
        self.messageLabel.text = message
    }
    
}

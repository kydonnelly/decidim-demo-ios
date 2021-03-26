//
//  IssueImageCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueImageCell: CustomTableViewCell {
    
    typealias ChangeImageBlock = () -> Void
    
    @IBOutlet var iconImageView: UIImageView!
    
    private var onChangeImage: ChangeImageBlock?
    
    public func setup(thumbnail: UIImage?, changeImageBlock: ChangeImageBlock?) {
        if let image = thumbnail {
            self.iconImageView.image = image
        } else {
            self.iconImageView.icon = .image
            self.iconImageView.iconColor = .gray
        }
        
        self.onChangeImage = changeImageBlock
    }
    
    @IBAction func didTapChangeImage(_ sender: Any) {
        self.onChangeImage?()
    }
    
}
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
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    private var onChangeImage: ChangeImageBlock?
    
    public func setup(thumbnailUrl: String?, changeImageBlock: ChangeImageBlock?) {
        self.iconImageView.setThumbnail(url: thumbnailUrl)
        self.onChangeImage = changeImageBlock
    }
    
    @IBAction func didTapChangeImage(_ sender: Any) {
        self.onChangeImage?()
    }
    
}

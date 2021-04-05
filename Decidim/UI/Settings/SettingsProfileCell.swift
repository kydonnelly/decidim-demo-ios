//
//  SettingsProfileCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class SettingsProfileCell: CustomTableViewCell {
    
    typealias ChangeImageBlock = () -> Void
    
    @IBOutlet var handleLabel: UILabel!
    @IBOutlet var pictureImageView: GiphyMediaView!
    
    private var onChangeImage: ChangeImageBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Support tapping the image to change it
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeImage(_:)))
        self.pictureImageView.addGestureRecognizer(gesture)
    }
    
    public func setup(profile: ProfileInfo, changeImageBlock: ChangeImageBlock?) {
        self.handleLabel.text = profile.handle
        self.pictureImageView.setThumbnail(url: profile.thumbnailUrl)
        
        self.onChangeImage = changeImageBlock
    }
    
    @IBAction func didTapChangeImage(_ sender: Any) {
        self.onChangeImage?()
    }
    
}

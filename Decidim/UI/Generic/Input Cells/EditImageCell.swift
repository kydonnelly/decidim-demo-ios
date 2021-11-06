//
//  IssueImageCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class EditImageCell: CustomTableViewCell {
    
    typealias ChangeImageBlock = (Bool) -> Void
    
    @IBOutlet var iconImageView: ThumbnailView!
    @IBOutlet var changeImageButton: ChoosePhotoButton!
    
    private var onChangeImage: ChangeImageBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Support tapping the image to change it
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeImage(_:)))
        self.iconImageView.addGestureRecognizer(gesture)
        
        self.changeImageButton.setup { [weak self] asGif in
            self?.changeImage(asGif: asGif)
        }
    }
    
    public func setup(thumbnailUrl: String?, changeImageBlock: ChangeImageBlock?) {
        self.iconImageView.setThumbnail(url: thumbnailUrl)
        self.onChangeImage = changeImageBlock
    }
    
    @IBAction func didTapChangeImage(_ sender: Any) {
        self.changeImage(asGif: false)
    }
    
    private func changeImage(asGif: Bool) {
        self.onChangeImage?(asGif)
    }
    
}

//
//  ProfileIconListAddCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ProfileIconCollectionCellAdd: UICollectionViewCell {
    
    typealias ActionBlock = () -> Void
    
    @IBOutlet var iconImageView: UIImageView!
    
    private var onAddTapped: ActionBlock?
    
    public func setup(actionBlock: ActionBlock?) {
        self.onAddTapped = actionBlock
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedImageView(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
    }
    
}

extension ProfileIconCollectionCellAdd {
    
    @IBAction func tappedImageView(_ sender: UIGestureRecognizer) {
        self.onAddTapped?()
    }
    
}

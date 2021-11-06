//
//  ChoosePhotoButton.swift
//  Decidim
//
//  Created by Kyle Donnelly on 11/6/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ChoosePhotoButton: PillButton {
    
    typealias MenuBlock = (Bool) -> Void
    
    private var menuBlock: MenuBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            self.addInteraction(UIContextMenuInteraction(delegate: self))
        }
    }
    
    public func setup(menuBlock: @escaping MenuBlock) {
        self.menuBlock = menuBlock
    }
    
}

// UIContextMenuInteractionDelegate
extension ChoosePhotoButton {
    
    @available(iOS 13.0, *)
    override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let provider: UIContextMenuActionProvider = { [weak self] suggestedActions in
            UIMenu(title: "", identifier: UIMenu.Identifier("com.cooperative4thecommunity.Decidim.editImageCell"), children: [
                UIAction(title: "Image", identifier: UIAction.Identifier("com.cooperative4thecommunity.Decidim.editImageCellImage")) { [weak self] action in
                    self?.menuBlock?(false)
                },
                UIAction(title: "GIF", identifier: UIAction.Identifier("com.cooperative4thecommunity.Decidim.editImageCellImageGif")) { [weak self] action in
                    self?.menuBlock?(true)
                }
            ])
        }
        
        return UIContextMenuConfiguration(identifier: "com.cooperative4thecommunity.Decidim.choosePhotoButton" as NSCopying, previewProvider: nil, actionProvider: provider)
    }
    
}

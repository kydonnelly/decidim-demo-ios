//
//  PillButton.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/30/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class PillButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.bounds.size
        self.layer.cornerRadius = min(size.width, size.height) * 0.5
    }
    
}

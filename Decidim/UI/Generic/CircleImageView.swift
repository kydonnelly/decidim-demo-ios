//
//  CircleImageView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {
    
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

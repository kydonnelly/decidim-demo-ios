//
//  AccessibleButton.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/9/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class AccessibleButton: UIButton {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) {
            return true
        }
        
        if abs(self.bounds.midX - point.x) <= 22.0 && abs(self.bounds.midY - point.y) <= 22.0 {
            return true
        }
        
        return false
    }
    
}

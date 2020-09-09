//
//  TouchThroughView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/8/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TouchThroughView : UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }
    
}

class TouchThroughCollectionView : UICollectionView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }
    
}

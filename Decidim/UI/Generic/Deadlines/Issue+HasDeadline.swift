//
//  Issue+HasDeadline.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/30/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

extension Issue: HasDeadline {
    
    var type: DeadlineType? {
        return .generic
    }
    
}

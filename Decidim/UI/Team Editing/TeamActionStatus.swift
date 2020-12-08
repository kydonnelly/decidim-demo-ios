//
//  TeamActionStatus.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/18/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

enum TeamActionStatus: String, CaseIterable {
    case unknown
    
    case proposed
    case pending
    case inProgress
    case ongoing
    case done
    case archived
}

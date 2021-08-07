//
//  TeamMemberStatus.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/16/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

enum TeamMemberStatus: String, CaseIterable {
    case active
    case requested
    case invited
    case banned
    
    case unknown
}

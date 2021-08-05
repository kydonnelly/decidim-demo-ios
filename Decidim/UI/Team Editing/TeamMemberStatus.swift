//
//  TeamMemberStatus.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/16/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

enum TeamMemberStatus: String, CaseIterable {
    case invited
    case requested
    case active
    case banned
    
    case unknown
}

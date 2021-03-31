//
//  Proposal+HasDeadline.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/30/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

extension Proposal: HasDeadline {
    
    var deadline: Date? {
        if let deadline = self.amendmentDeadline, deadline.isFuture {
            return deadline
        } else {
            return self.votingDeadline
        }
    }
    
    var type: DeadlineType? {
        if let deadline = self.amendmentDeadline, deadline.isFuture {
            return .amendment
        } else {
            return .voting
        }
    }
    
}

//
//  VoteDelegationManager.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/29/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class VoteDelegationManager {
    
    public typealias UpdateCompletion = (Bool) -> Void
    
    private var byCategory: [String: [Int]] = [:]
    
    public func updateDelegates(category: String, profileIds: [Int], completion: UpdateCompletion) {
        self.byCategory[category] = profileIds
        completion(true)
    }
    
    public func getDelegates(category: String) -> [Int] {
        return self.byCategory[category] ?? []
    }
    
    public var allCategories: [String] {
        return ["Transportation", "Housing", "Public Safety", "Services", "Parks & Libraries"]
    }
    
}

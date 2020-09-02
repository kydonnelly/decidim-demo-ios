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
    private var backingDataController: TeamListDataController
    
    init() {
        self.backingDataController = TeamListDataController.shared()
    }
    
    public func updateDelegates(category: String, profileIds: [Int], completion: UpdateCompletion) {
        self.byCategory[category] = profileIds
        completion(true)
    }
    
    public func getDelegates(category: String) -> [Int] {
        return self.byCategory[category] ?? []
    }
    
    public var allCategories: [String] {
        var categories = ["Global"]
        
        if let myProfileId = MyProfileController.shared.myProfileId {
            categories.append(contentsOf: self.backingDataController.allTeams.filter { $0.memberList[myProfileId] != nil }.compactMap { $0.team.name })
        }
        
        return categories
    }
    
}

extension VoteDelegationManager {
    
    public func refresh(completion: (() -> Void)?) {
        self.backingDataController.refresh { dc in
            completion?()
        }
    }
    
    var doneLoading: Bool {
        return self.backingDataController.donePaging
    }
    
}

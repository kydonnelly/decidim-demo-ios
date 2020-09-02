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
    
    private var backingDataController: TeamListDataController
    
    init() {
        self.backingDataController = TeamListDataController.shared()
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

extension VoteDelegationManager {
    
    public func getDelegates(category: String) -> [Int] {
        guard let profileId = MyProfileController.shared.myProfileId else {
            return []
        }
        guard let team = TeamListDataController.shared().allTeams.first(where: { $0.team.name == category }) else {
            return []
        }
        guard let delegates = team.delegationList[profileId] else {
            return []
        }
        return delegates
    }
    
    public func updateDelegates(category: String, profileIds: [Int], completion: @escaping UpdateCompletion) {
        guard let profileId = MyProfileController.shared.myProfileId else {
            completion(false)
            return
        }
        guard let team = TeamListDataController.shared().allTeams.first(where: { $0.team.name == category }) else {
            completion(false)
            return
        }
        
        var delegationList = team.delegationList
        delegationList[profileId] = profileIds
        
        TeamListDataController.shared().editTeam(team.team.id, title: team.team.name, description: team.team.description, thumbnail: team.team.thumbnail, members: team.memberList, actions: team.actionList, delegates: delegationList) { error in
            completion(error == nil)
        }
    }
    
}

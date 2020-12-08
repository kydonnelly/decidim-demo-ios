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
    
    public static var shared = VoteDelegationManager()
    
    private var backingDataController: TeamListDataController
    private var globalDataController: DelegationDataController
    
    init() {
        self.backingDataController = TeamListDataController.shared()
        self.globalDataController = DelegationDataController.shared()
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
        var globalRefreshed = false
        var othersRefreshed = false
        
        self.backingDataController.refresh { dc in
            othersRefreshed = true
            if globalRefreshed && othersRefreshed {
                completion?()
            }
        }
        
        self.globalDataController.refresh { dc in
            globalRefreshed = true
            if globalRefreshed && othersRefreshed {
                completion?()
            }
        }
    }
    
    var doneLoading: Bool {
        return self.backingDataController.donePaging && self.globalDataController.donePaging
    }
    
}

extension VoteDelegationManager {
    
    public func getDelegates(category: String) -> [Int] {
        if category == "Global" {
            guard let delegate = self.globalDataController.delegates["Global"] else {
                return []
            }
            return [delegate.delegateId]
        }
        
        guard let profileId = MyProfileController.shared.myProfileId else {
            return []
        }
        guard let team = self.backingDataController.allTeams.first(where: { $0.team.name == category }) else {
            return []
        }
        guard let delegates = team.delegationList[profileId] else {
            return []
        }
        return delegates
    }
    
    public func updateDelegates(category: String, profileIds: [Int], completion: @escaping UpdateCompletion) {
        if category == "Global" {
            if let profileId = profileIds.first {
                self.globalDataController.addDelegate(profileId) { error in
                    completion(error == nil)
                }
            } else {
                self.globalDataController.deleteDelegate { error in
                    completion(error == nil)
                }
            }
            return
        }
        
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
        
        TeamListDataController.shared().editTeam(team.team.id, title: team.team.name, description: team.team.description, thumbnail: team.team.thumbnail, members: team.memberList, delegates: delegationList) { error in
            completion(error == nil)
        }
    }
    
}

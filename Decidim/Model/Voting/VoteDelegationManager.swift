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
    
    private var globalDataController: DelegationDataController
    
    init() {
        self.globalDataController = DelegationDataController.shared()
    }
    
    public var allCategories: [String] {
        return ["Global"]
    }
    
}

extension VoteDelegationManager {
    
    public func refresh(completion: ((Error?) -> Void)?) {
        self.globalDataController.refresh(failBlock: { error in
            completion?(error)
        }, successBlock: { dc in
            completion?(nil)
        })
    }
    
    var doneLoading: Bool {
        return self.globalDataController.donePaging
    }
    
}

extension VoteDelegationManager {
    
    public func getDelegates(category: String) -> [Int] {
        guard let delegate = self.globalDataController.delegates["Global"] else {
            return []
        }
        return [delegate.delegateId]
    }
    
    public func updateDelegate(category: String, profileId: Int?, completion: @escaping UpdateCompletion) {
        if let profileId = profileId {
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
    
}

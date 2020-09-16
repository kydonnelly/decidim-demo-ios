//
//  DelegationDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation

class DelegationDataController: NetworkDataController {
    
    private var localDelegates: [String: Delegate] = [:]
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        HTTPRequest.shared.get(endpoint: "delegations") { response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard var delegationInfo = response?["delegation"] as? [String: Any] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            delegationInfo["category"] = "Global"
            guard let delegation = Delegate.from(dict: delegationInfo) else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            completion([delegation], Cursor(next: "", done: true), nil)
        }
    }
    
    public var delegates: [String: Delegate] {
        var delegates = self.localDelegates
        if let data = self.data as? [Delegate] {
            for delegate in data {
                delegates[delegate.category] = delegate
            }
        }
        
        return delegates
    }
    
    public func addDelegate(_ userId: Int, completion: @escaping (Error?) -> Void) {
        let payload: [String: Any] = ["delegation": ["delegate_id": userId]]
        
        HTTPRequest.shared.post(endpoint: "delegations", payload: payload) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard var delegationInfo = response?["delegation"] as? [String: Any] else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            delegationInfo["category"] = "Global"
            guard let delegate = Delegate.from(dict: delegationInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localDelegates["Global"] = delegate
            completion(nil)
        }
    }
    
    public func editDelegate(_ userId: Int, completion: @escaping (Error?) -> Void) {
        self.addDelegate(userId, completion: completion)
    }
    
    public func deleteDelegate(completion: @escaping (Error?) -> Void) {
        HTTPRequest.shared.delete(endpoint: "delegations") { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "deleted" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            
            self?.localDelegates.removeAll()
            self?.data?.removeAll()
            
            completion(nil)
        }
    }
    
}

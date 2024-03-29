//
//  IssueFollowersDataController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 4/10/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

class IssueFollowersDataController: NetworkDataController {
    
    private var backingIssueId: Int!
    private var localFollowers: [IssueFollower] = []
    
    static func shared(issueId: Int) -> Self {
        let controller = self.shared(keyInfo: "\(issueId)")
        controller.backingIssueId = issueId
        return controller
    }
    
    override func fetchPage(cursor: NetworkDataController.Cursor, completion: @escaping ([Any]?, NetworkDataController.Cursor?, Error?) -> Void) {
        let issueId = self.backingIssueId!
        
        HTTPRequest.shared.get(endpoint: "issues", args: ["\(issueId)", "follows"]) { [weak self] response, error in
            guard error == nil else {
                completion(nil, Cursor(next: "error", done: true), error)
                return
            }
            guard let followerInfos = response?["issue_follows"] as? [[String: Any]] else {
                completion(nil, Cursor(next: "error", done: true), HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localFollowers.removeAll()
            let followers = followerInfos.compactMap { IssueFollower.from(dict: $0) }
            completion(followers, Cursor(next: "", done: true), nil)
        }
    }
    
    public var allFollowers: [IssueFollower] {
        var followers = self.localFollowers
        if let data = self.data as? [IssueFollower] {
            followers.append(contentsOf: data)
        }
        
        return followers
    }
    
    public func addFollower(completion: @escaping (Error?) -> Void) {
        let issueId = String(describing: self.backingIssueId!)
        
        HTTPRequest.shared.post(endpoint: "issues", args: [issueId, "follows"], payload: [:]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard let followerInfo = response?["issue_follow"] as? [String: Any],
                  let follower = IssueFollower.from(dict: followerInfo) else {
                completion(HTTPRequest.RequestError.parseError(response: response))
                return
            }
            
            self?.localFollowers.append(follower)
            completion(nil)
        }
    }
    
    public func removeFollower(_ follower: IssueFollower, completion: @escaping (Error?) -> Void) {
        let issueId = String(describing: self.backingIssueId!)
        let followId = "\(follower.followId)"
        
        HTTPRequest.shared.delete(endpoint: "issues", args: [issueId, "follows", followId]) { [weak self] response, error in
            guard error == nil else {
                completion(error)
                return
            }
            guard response?["status"] as? String == "deleted" else {
                completion(HTTPRequest.RequestError.statusError(response: response))
                return
            }
            
            if let localIndex = self?.localFollowers.firstIndex(where: { $0.followId == follower.followId }) {
                self?.localFollowers.remove(at: localIndex)
            }
            if let localIndex = self?.data?.firstIndex(where: { ($0 as? IssueFollower)?.followId == follower.followId }) {
                self?.data?.remove(at: localIndex)
            }
            
            completion(nil)
        }
    }
    
}

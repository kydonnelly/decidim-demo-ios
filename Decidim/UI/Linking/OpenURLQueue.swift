//
//  OpenURLQueue.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/12/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation
import UIKit

class OpenURLQueue: NSObject {
    
    private enum Route {
        case team(id: Int)
        case issue(id: Int)
        case proposal(id: Int)
        case issueComment(issueId: Int, commentId: Int?)
        case proposalComment(proposalId: Int, commentId: Int?)
        
        init?(host: String, args: [String]) {
            switch host {
            case "groups":
                guard let first = args.first, let teamId = Int(first) else {
                    return nil
                }
                self = .team(id: teamId)
            case "issues":
                guard let first = args.first, let issueId = Int(first) else {
                    return nil
                }
                self = .issue(id: issueId)
            case "proposals":
                guard let first = args.first, let proposalId = Int(first) else {
                    return nil
                }
                self = .proposal(id: proposalId)
            case "comments":
                guard let first = args.first, let last = args.last, let id = Int(last) else {
                    return nil
                }
                switch first {
                case "issue":
                    self = .issueComment(issueId: id, commentId: nil)
                case "proposal":
                    self = .proposalComment(proposalId: id, commentId: nil)
                default:
                    return nil
                }
            default:
                return nil
            }
        }
    }
    
    private var urlQueue = [URL]()
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(routeIfPossible), name: MyProfileController.profileUpdatedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addURL(_ url: URL) -> Bool {
        guard url.scheme?.caseInsensitiveCompare("votionapp") == .orderedSame else {
            return false
        }
        
        let arguments = url.pathComponents.filter { $0 != "/"}
        
        guard let host = url.host, Route(host: host, args: arguments) != nil else {
            return false
        }
        
        self.urlQueue.insert(url, at: 0)
        
        self.routeIfPossible()
        
        return true
    }
    
    @discardableResult
    @objc func routeIfPossible() -> Bool {
        guard MyProfileController.shared.isRegistered else {
            return false
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let tvc = appDelegate.window?.rootViewController as? UITabBarController,
              let nvc = tvc.selectedViewController?.children.first as? UINavigationController else {
            return false
        }
        
        guard let url = self.urlQueue.popLast() else {
            return false
        }
        
        return self.route(to: url, navigationController: nvc)
    }
    
    func route(to url: URL, navigationController: UINavigationController) -> Bool {
        let arguments = url.pathComponents.filter { $0 != "/"}
        
        guard let host = url.host, let route = Route(host: host, args: arguments) else {
            return false
        }
        
        switch route {
        case let .team(teamId):
            let teamVC = TeamDetailViewController.create(teamId: teamId)
            navigationController.pushViewController(teamVC, animated: true)
        case let .issue(issueId):
            let issueVC = IssueDetailViewController.create(issueId: issueId)
            navigationController.pushViewController(issueVC, animated: true)
        case let .proposal(proposalId):
            let proposalVC = ProposalDetailViewController.create(proposalId: proposalId)
            navigationController.pushViewController(proposalVC, animated: true)
        case let .issueComment(issueId, commentId):
            let commentVC = CommentListViewController.create(issueId: issueId, focusComment: nil)
            navigationController.pushViewController(commentVC, animated: true)
        case let .proposalComment(proposalId, commentId):
            let commentVC = CommentListViewController.create(proposalId: proposalId, focusComment: nil)
            navigationController.pushViewController(commentVC, animated: true)
        }
        
        return true
    }
    
}

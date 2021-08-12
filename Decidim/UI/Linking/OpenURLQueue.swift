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
        
        init?(host: String, args: [String]) {
            switch host {
            case "groups":
                guard let first = args.first, let teamId = Int(first) else {
                    return nil
                }
                self = .team(id: teamId)
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
        case .team:
            guard let target = arguments.first, let teamId = Int(target) else {
                return false
            }
            
            let teamVC = TeamDetailViewController.create(teamId: teamId
            navigationController.pushViewController(teamVC, animated: true)
        }
        
        return true
    }
    
}

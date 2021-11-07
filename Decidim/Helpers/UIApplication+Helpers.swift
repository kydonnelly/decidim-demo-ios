//
//  UIApplication+Helpers.swift
//  Decidim
//
//  Created by Kyle Donnelly on 11/6/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

extension Dictionary where Key == UIApplication.LaunchOptionsKey {
    
    var pushNotificationRoute: URL? {
        guard let options = self[.remoteNotification] as? [AnyHashable: AnyObject] else {
            return nil
        }
        
        return options.pushNotificationRoute
    }
    
}

extension Dictionary where Key == AnyHashable {
    
    var pushNotificationRoute: URL? {
        guard let payload = self["aps"] as? [String: AnyObject] else {
            return nil
        }
        
        guard let route = payload["route"] as? String else {
            return nil
        }
        
        return URL(string: route)
    }
    
}

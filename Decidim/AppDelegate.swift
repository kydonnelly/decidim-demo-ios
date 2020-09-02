//
//  AppDelegate.swift
//  Decidim
//
//  Created by Kyle Donnelly on 5/24/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let tabController = self.window?.rootViewController as? UITabBarController {
            tabController.delegate = self
        }
        
        self.setupAppAppearance()
        
        return true
    }

}

extension AppDelegate: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController === viewController {
            if let navController = viewController.children.first as? UINavigationController {
                if let tableController = navController.topViewController as? CustomTableController {
                    if tableController.scrollToTop() {
                        // scroll instead of pop
                        return true
                    }
                }
                
                navController.popToRootViewController(animated: true)
            }
        }
        
        return true
    }
    
}


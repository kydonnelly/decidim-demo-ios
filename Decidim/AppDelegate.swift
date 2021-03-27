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
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        HTTPRequest.environment = .staging
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let tabController = self.window?.rootViewController as? UITabBarController {
            tabController.delegate = self
            tabController.selectedIndex = 0 // home
            
            // named colors aren't available until after the trait collection is known :(
            tabController.viewControllers?.forEach {
                $0.tabBarItem._iconColor = .detailDark
                $0.tabBarItem._selectedIconColor = .action
            }
        }
        
        self.setupAppAppearance()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let rootVC = self.window?.rootViewController else {
            return
        }
        guard !(rootVC.presentedViewController is RegistrationViewController) else {
            return
        }
        
        if !MyProfileController.shared.isRegistered {
            let registrationVC = RegistrationViewController.create()
            registrationVC.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(registrationVC, animated: false, completion: nil)
        }
    }

}

extension AppDelegate: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard MyProfileController.shared.isRegistered else {
            return viewController.children.first?.isKind(of: ProfileViewController.self) == true
        }
        
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


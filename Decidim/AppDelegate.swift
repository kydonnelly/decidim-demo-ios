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
    
    let urlQueue = OpenURLQueue()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        HTTPRequest.environment = .staging
        
        PushNotificationManager.shared.configure(urlQueue: self.urlQueue)
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let tabController = self.window?.rootViewController as? UITabBarController {
            tabController.delegate = self
            tabController.selectedIndex = 0 // home
            
            // named colors aren't available until after the trait collection is known :(
            tabController.viewControllers?.forEach {
                $0.tabBarItem._iconColor = .secondaryBackground
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
        
        let configurePushNotifications: () -> Void = {
            PushNotificationManager.shared.requestAuthorization {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        if MyProfileController.shared.isRegistered {
            configurePushNotifications()
        } else {
            let registrationVC = RegistrationViewController.create() { [weak self] type in
                switch type {
                case .newUser:
                    // Wait until second launch to configure APNs
                    break
                case .existingUser:
                    configurePushNotifications()
                }
                
                self?.urlQueue.routeIfPossible()
            }
            
            registrationVC.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(registrationVC, animated: false, completion: nil)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.urlQueue.addURL(url)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.shared.registerToken(data: deviceToken) { [weak self] error in
            if let e = error {
                let alert = UIAlertController(title: "Error", message: "Failed to register for push notifications: \(e)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { [weak weakAlert = alert] _ in
                    weakAlert?.dismiss(animated: true, completion: nil)
                }))
                self?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: "Could not register for push notifications: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { [weak weakAlert = alert] _ in
            weakAlert?.dismiss(animated: true, completion: nil)
        }))
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let route = userInfo.pushNotificationRoute else {
            completionHandler(.failed)
            return
        }
        
        guard self.urlQueue.addURL(route) else {
            completionHandler(.failed)
            return
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


//
//  PushNotificationManager.swift
//  Decidim
//
//  Created by Kyle Donnelly on 11/6/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit
import UserNotifications

class PushNotificationManager: NSObject {
    
    typealias AuthorizedBlock = () -> Void
    
    public static var shared = PushNotificationManager()
    
    public func configure(onAuthorizedBlock: AuthorizedBlock? = nil) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard error == nil else {
                print("Error")
                return
            }
            
            guard granted else {
                print("Denied")
                return
            }
            
            // What did they actually grant?
            self.refreshGrantedSettings { settings in
                switch settings.authorizationStatus {
                case .authorized:
                    onAuthorizedBlock?()
                case .ephemeral, .provisional:
                    break
                case .denied, .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func refreshGrantedSettings(completion: ((UNNotificationSettings) -> Void)?) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion?(settings)
        }
    }
    
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will present notification")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("did receive notification response")
    }
    
}

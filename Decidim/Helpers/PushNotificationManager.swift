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
    
    private weak var urlQueue: OpenURLQueue?
    
    public func configure(urlQueue: OpenURLQueue) {
        self.urlQueue = urlQueue
        UNUserNotificationCenter.current().delegate = self
    }
    
    public func requestAuthorization(onAuthorizedBlock: AuthorizedBlock? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard error == nil else {
                print("Error")
                return
            }
            
            guard granted else {
                return
            }
            
            self.registerRichNotificationActions()
            
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

extension PushNotificationManager {
    
    fileprivate enum ActionIdentifiers: String {
        case view
        case reply
        case accept
        case decline
        case voteYes
        case voteNo
        
        var identifier: String {
            return "com.cooperative4thecommunity.Decidim.PushAction.\(self.rawValue)"
        }
        
        init?(identifier: String) {
            guard let rawValue = identifier.components(separatedBy: ".").last else { return nil }
            self.init(rawValue: rawValue)
        }
    }
    
    fileprivate enum CategoryIdentifiers: String {
        case comment
        case proposal
        case deadline
        case invite
        
        var identifier: String {
            return "com.cooperative4thecommunity.Decidim.PushCategory.\(self.rawValue)"
        }
    }
    
    private func registerRichNotificationActions() {
        let viewAction = UNNotificationAction(identifier: ActionIdentifiers.view.identifier,
                                              title: "View",
                                              options: [.foreground])
        
        let replyAction = UNNotificationAction(identifier: ActionIdentifiers.reply.identifier,
                                              title: "Reply",
                                              options: [.foreground])
        
        let acceptAction = UNNotificationAction(identifier: ActionIdentifiers.accept.identifier,
                                              title: "Accept",
                                              options: [.foreground])
        
        let declineAction = UNNotificationAction(identifier: ActionIdentifiers.decline.identifier,
                                              title: "Decline",
                                              options: [.foreground])
        
        let voteYesAction = UNNotificationAction(identifier: ActionIdentifiers.voteYes.identifier,
                                              title: "No",
                                              options: [.foreground])
        
        let voteNoAction = UNNotificationAction(identifier: ActionIdentifiers.voteNo.identifier,
                                              title: "Yes",
                                              options: [.foreground])
        
        let commentCategory = UNNotificationCategory(identifier: CategoryIdentifiers.comment.identifier,
                                                     actions: [viewAction, replyAction],
                                                     intentIdentifiers: [],
                                                     options: [])
        
        let proposalCategory = UNNotificationCategory(identifier: CategoryIdentifiers.proposal.identifier,
                                                     actions: [viewAction],
                                                     intentIdentifiers: [],
                                                     options: [])
        
        let deadlineCategory = UNNotificationCategory(identifier: CategoryIdentifiers.deadline.identifier,
                                                     actions: [viewAction, voteYesAction, voteNoAction],
                                                     intentIdentifiers: [],
                                                     options: [])
        
        let invitationCategory = UNNotificationCategory(identifier: CategoryIdentifiers.invite.identifier,
                                                     actions: [viewAction, acceptAction, declineAction],
                                                     intentIdentifiers: [],
                                                     options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([commentCategory,
                                                                      proposalCategory,
                                                                      deadlineCategory,
                                                                      invitationCategory])
    }
    
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("will present notification")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer {
            completionHandler()
        }
        
        guard var route = response.notification.request.content.userInfo.pushNotificationRoute else {
            return
        }
        
        // encode selected action into the URL as the trailing component
        if let action = ActionIdentifiers(identifier: response.actionIdentifier) {
            route.appendPathComponent(action.rawValue)
        }
        
        _ = self.urlQueue?.addURL(route)
    }
    
}

extension PushNotificationManager {
    
    func registerToken(data: Data) {
        guard let profileId = MyProfileController.shared.myProfileId else {
            return
        }
        
        let token = data.map { String(format: "%02.2hhx", $0) }.joined()
        guard token.count > 0 else {
            return
        }
        
        let args = [String(describing: profileId), "ios_token"]
        let payload: [String: Any] = ["token": ["value": token]]
        
        HTTPRequest.shared.put(endpoint: "users", args: args, payload: payload) { response, error in
            guard error == nil else {
                return
            }
        }
    }
    
}

//
//  NotificationService.swift
//  com.cooperative4thecommunity.DecidimNotificationService
//
//  Created by Kyle Donnelly on 11/7/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        // https://pskb-prod.herokuapp.com/swift/creating-ios-rich-push-notifications
        guard let content = request.content.mutableCopy() as? UNMutableNotificationContent,
              let info = content.userInfo["info"] as? [String: Any],
              let thumbnailUrl = info["thumbnail_url"] as? String else {
            contentHandler(request.content)
            return
        }
        
        let completion: (Data?) -> Void = { data in
            guard let data = data, let attachment = UNNotificationAttachment(identifier: thumbnailUrl, data: data, options: nil) else {
                contentHandler(request.content)
                return
            }
            
            content.title = content.title.appending(" \(thumbnailUrl)")
            content.attachments = [attachment]
            guard let copy = content.copy() as? UNNotificationContent else {
                contentHandler(request.content)
                return
            }
            
            contentHandler(copy as UNNotificationContent)
        }
        
        if let imageURL = URL(awsString: thumbnailUrl) {
            _ = AWSManager.shared.downloadData(url: imageURL, completion: { data in
                completion(data)
            })
        } else {
            GiphyManager.shared.loadGifData(id: thumbnailUrl, completion: { data in
                completion(data)
            })
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

extension UNNotificationAttachment {
    
    fileprivate convenience init?(identifier: String, data: Data, options: [NSObject : AnyObject]?) {
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory())
        guard let path = tempDirectory.appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true) else {
            return nil
        }
        
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            let fileURL = path.appendingPathComponent(identifier)
            try data.write(to: fileURL)
            try self.init(identifier: identifier, url: fileURL, options: options)
        } catch let error {
            print("Could not create attachment: \(error)")
            return nil
        }
    }
    
}

//
//  Team.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/14/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

struct Team {
    let id: Int
    let name: String
    let description: String
    let thumbnailUrl: String?
    let createdAt: Date
    let memberCount: Int
    
    public static func from(dict: [String: Any], memberCount: Int = 0, description: String? = nil) -> Team? {
        guard let teamId = dict["id"] as? Int,
              let title = dict["title"] as? String,
              let body = description ?? dict["body"] as? String,
              let createdAt = dict["created_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt) else {
            return nil
        }
        
        return Team(id: teamId,
                    name: title,
                    description: body,
                    thumbnailUrl: nil,
                    createdAt: createdDate,
                    memberCount: memberCount)
    }
}

extension Team {
    
    var thumbnail: UIImage? {
        if let url = self.thumbnailUrl {
            // todo: load and return image
            return nil
        }
        
        let dimension: CGFloat = 128
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: dimension, height: dimension), false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        let locations: [CGFloat] = [0.0, 1.0]
        let cgColors = [UIColor.generateColor(seed: UInt(abs(self.id))).cgColor,
                        UIColor.generateColor(seed: UInt(abs(Int(Int16.max) - self.id))).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations) else {
            return nil
        }
        
        let absoluteStartPoint = CGPoint.zero
        let absoluteEndPoint = CGPoint(x: dimension, y: dimension)
        
        context.drawLinearGradient(gradient, start: absoluteStartPoint, end: absoluteEndPoint, options: [])
        
        let text = String(describing: self.id)
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: dimension * 0.6),
                              NSAttributedString.Key.foregroundColor: UIColor.white]
        let textRect = CGRect(x: dimension * 0.1, y: dimension * 0.1,
                              width: dimension * 0.8, height: dimension * 0.8)
        
        (text as NSString).draw(in: textRect, withAttributes: textAttributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

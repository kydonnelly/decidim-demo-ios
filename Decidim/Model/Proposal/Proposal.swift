//
//  Proposal.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

struct Proposal {
    let id: Int
    let authorId: Int
    let title: String
    let body: String
    let iconUrl: String?
    let createdAt: Date
    let updatedAt: Date
    let commentCount: Int
    let voteCount: Int
    
    public static func from(dict: [String: Any]) -> Proposal? {
        guard let proposalId = dict["id"] as? Int,
              let authorId = dict["user_id"] as? Int,
              let title = dict["title"] as? String,
              let body = dict["body"] as? String,
              let createdAt = dict["created_at"] as? String,
              let updatedAt = dict["updated_at"] as? String else {
            return nil
        }
        
        guard let createdDate = Date(timestamp: createdAt),
              let updatedDate = Date(timestamp: updatedAt) else {
            return nil
        }
        
        return Proposal(id: proposalId,
                        authorId: authorId,
                        title: title,
                        body: body,
                        iconUrl: nil,
                        createdAt: createdDate,
                        updatedAt: updatedDate,
                        commentCount: 0,
                        voteCount: 0)
    }
}

extension Proposal {
    
    var thumbnail: UIImage? {
        if let url = self.iconUrl {
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

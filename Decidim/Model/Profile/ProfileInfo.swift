//
//  ProfileInfo.swift
//  Decidim
//
//  Created by Kyle Donnelly on 6/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import Foundation
import UIKit

struct ProfileInfo {
    let profileId: Int
    let handle: String
    let thumbnailUrl: String?
    
    public static func from(dict: [String: Any]) -> ProfileInfo? {
        guard let profileId = dict["id"] as? Int,
              let handle = dict["name"] as? String else {
            return nil
        }
        
        return ProfileInfo(profileId: profileId,
                           handle: handle,
                           thumbnailUrl: nil)
    }
}

extension ProfileInfo {
    
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
        let cgColors = [UIColor.generateColor(seed: UInt(abs(self.profileId))).cgColor,
                        UIColor.generateColor(seed: UInt(abs(Int(Int16.max) - self.profileId))).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations) else {
            return nil
        }
        
        let absoluteStartPoint = CGPoint.zero
        let absoluteEndPoint = CGPoint(x: dimension, y: dimension)
        
        context.drawLinearGradient(gradient, start: absoluteStartPoint, end: absoluteEndPoint, options: [])
        
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: dimension * 0.6),
                              NSAttributedString.Key.foregroundColor: UIColor.white]
        let textRect = CGRect(x: dimension * 0.1, y: dimension * 0.1,
                              width: dimension * 0.8, height: dimension * 0.8)
        
        (self.handle as NSString).substring(to: 2).draw(in: textRect, withAttributes: textAttributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

//
//  GiphyManager.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/29/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import GiphyUISDK

class GiphyManager {
    
    public static var shared = GiphyManager()
    
    public func configure() -> Bool {
        guard let key = self.apiKey else {
            return false
        }
        
        Giphy.configure(apiKey: key)
        return true
    }
    
    private var apiKey: String? {
        guard let plistPath = Bundle.main.path(forResource: "Giphy-Info", ofType: "plist"),
              let plistContents = NSDictionary(contentsOfFile: plistPath) else {
          return nil
        }
        
        return plistContents.object(forKey: "API_KEY") as? String
    }
    
}

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
    
    init() {
        precondition(self.configure())
        
        // In case Giphy doesn't handle this themselves
        NotificationCenter.default.addObserver(self, selector: #selector(clearCache), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
}

extension GiphyManager {
    
    fileprivate func configure() -> Bool {
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

extension GiphyManager {
    
    typealias LoadGifBlock = (GPHMedia?) -> Void
    
    public func loadGif(id: String, completion: @escaping LoadGifBlock) -> Operation {
        return GiphyCore.shared.gifByID(id) { response, error in
            DispatchQueue.main.async {
                completion(response?.data)
            }
        }
    }
    
    public func giphyViewController(delegate: GiphyDelegate) -> GiphyViewController {
        let giphyVC = GiphyViewController()
        giphyVC.delegate = delegate
        
        giphyVC.mediaTypeConfig = [.gifs, .text, .emoji, .stickers, .recents]
        giphyVC.theme = GiphyTheme(type: .automatic)
        giphyVC.stickerColumnCount = .three
        giphyVC.rating = .ratedPG13
        giphyVC.renditionType = .fixedHeight
        giphyVC.shouldLocalizeSearch = true
        
        return giphyVC
    }
    
}

extension GiphyManager {
    
    @objc public func clearCache() {
        GPHCache.shared.clear()
    }
    
}

class GiphyTheme: GPHTheme {
    
}

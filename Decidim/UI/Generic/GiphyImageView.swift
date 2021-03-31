//
//  GiphyImageView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/30/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import GiphyUISDK
import KTDIconFont
import UIKit

typealias GiphyMediaView = GPHMediaView

extension GPHMediaView {
    
    fileprivate static var LoadOperationKey: UInt8 = 0
    private var mediaLoadOperation: Operation? {
        get {
            return objc_getAssociatedObject(self, &Self.LoadOperationKey) as? Operation
        }
        set {
            objc_setAssociatedObject(self, &Self.LoadOperationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func setThumbnail(url: String?) {
        self.mediaLoadOperation?.cancel()
        
        if let gifId = url {
            self.mediaLoadOperation = GiphyManager.shared.loadGif(id: gifId, completion: { [weak self] media in
                self?.mediaLoadOperation = nil
                
                if let media = media {
                    self?.useMedia(media)
                } else {
                    self?.useFallbackIcon()
                }
            })
        } else {
            self.mediaLoadOperation = nil
            self.useFallbackIcon()
        }
    }
    
    private func useMedia(_ media: GPHMedia) {
        self.media = media
        self.layer.cornerRadius = 0
    }
    
    private func useFallbackIcon() {
        self.refreshIconAppearance()
        self.layer.cornerRadius = 4
    }
    
    
}

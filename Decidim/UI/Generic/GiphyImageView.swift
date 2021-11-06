//
//  GiphyImageView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/30/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import AWSS3
import GiphyUISDK
import KTDIconFont
import UIKit

typealias ThumbnailView = GPHMediaView

extension GPHMediaView {
    
    fileprivate static var GiphyLoadOperationKey: UInt8 = 0
    private var giphyLoadOperation: Operation? {
        get {
            return objc_getAssociatedObject(self, &Self.GiphyLoadOperationKey) as? Operation
        }
        set {
            objc_setAssociatedObject(self, &Self.GiphyLoadOperationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate static var AWSLoadOperationKey: UInt8 = 0
    private var awsLoadOperation: AWSTask<AWSS3TransferUtilityDownloadTask>? {
        get {
            return objc_getAssociatedObject(self, &Self.AWSLoadOperationKey) as? AWSTask<AWSS3TransferUtilityDownloadTask>
        }
        set {
            objc_setAssociatedObject(self, &Self.AWSLoadOperationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func setThumbnail(url: String?) {
        self.awsLoadOperation?.result?.cancel()
        self.giphyLoadOperation?.cancel()
        self.awsLoadOperation = nil
        self.giphyLoadOperation = nil
        
        guard let thumbnailURL = url else {
            self.useFallbackIcon()
            return
        }
        
        if let imageURL = URL(awsString: thumbnailURL) {
            self.awsLoadOperation = AWSManager.shared.downloadImage(url: imageURL, completion: { [weak self] image in
                self?.awsLoadOperation = nil
                
                if let image = image {
                    self?.useImage(image)
                } else {
                    self?.useFallbackIcon()
                }
            })
        } else {
            self.giphyLoadOperation = GiphyManager.shared.loadGif(id: thumbnailURL, completion: { [weak self] media in
                self?.giphyLoadOperation = nil
                
                if let media = media {
                    self?.useMedia(media)
                } else {
                    self?.useFallbackIcon()
                }
            })
        }
    }
    
    private func useImage(_ image: UIImage) {
        self.image = image
        self.layer.cornerRadius = 0
    }
    
    private func useMedia(_ media: GPHMedia) {
        self.media = media
        self.layer.cornerRadius = 0
    }
    
    private func useFallbackIcon() {
        self.refreshIconAppearance()
        
        if self.iconInset < 4 {
            self.layer.cornerRadius = 2
        } else if self.iconInset < 8 {
            self.layer.cornerRadius = 4
        } else {
            self.layer.cornerRadius = 8
        }
    }
    
    
}

//
//  UIImagePickerController+Helpers.swift
//  Decidim
//
//  Created by Kyle Donnelly on 11/6/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

//import Photos
import UIKit

extension Dictionary where Key == UIImagePickerController.InfoKey {
    
    var imageURL: URL? {
        return self[.imageURL] as? URL
    }
    
    var mediaImage: UIImage? {
        if let image = self[.editedImage] as? UIImage {
            return image
        }
        
        if let image = self[.originalImage] as? UIImage {
            return image
        }
        
//        if let photo = info[.livePhoto] as? PHLivePhoto, let image = PHAssetResource.assetResources(for: photo).first {
//            PHAssetResourceManager.default().requestData(for: image, options: nil, dataReceivedHandler: { data in
//                print(data)
//            }, completionHandler: { error in
//                if let e = error {
//                    print(e)
//                }
//            })
//
//            return nil
//        }
        
        return nil
    }
    
}

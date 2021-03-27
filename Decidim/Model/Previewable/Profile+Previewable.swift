//
//  Profile+Previewable.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

extension ProfileInfoDataController: PreviewableDataController {
    
    var previewItems: [Previewable] {
        if let data = self.data as? [ProfileInfo] {
            return data
        } else {
            return []
        }
    }
    
}

extension ProfileInfo: Previewable {
    
    var previewTitle: String {
        return self.handle
    }
    
    var previewBody: String {
        return ""
    }
    
    var previewThumbnail: UIImage? {
        return self.thumbnail
    }
    
}

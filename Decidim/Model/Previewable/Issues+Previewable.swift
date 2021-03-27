//
//  Issues+Previewable.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

extension PublicIssueDataController: PreviewableDataController {
    
    var previewItems: [Previewable] {
        return self.allIssues
    }
    
}

extension Issue: Previewable {
    
    var previewTitle: String {
        return self.title
    }
    
    var previewBody: String {
        return self.body
    }
    
    var previewThumbnail: UIImage? {
        return self.thumbnail
    }
    
}

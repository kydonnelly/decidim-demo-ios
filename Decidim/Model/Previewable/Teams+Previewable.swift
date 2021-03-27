//
//  Teams+Previewable.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

extension TeamListDataController: PreviewableDataController {
    
    var previewItems: [Previewable] {
        return self.allTeams
    }
    
}

extension TeamDetail: Previewable {
    
    var previewTitle: String {
        return self.team.name
    }
    
    var previewBody: String {
        return self.team.description
    }
    
    var previewThumbnail: UIImage? {
        return self.team.thumbnail
    }
    
}

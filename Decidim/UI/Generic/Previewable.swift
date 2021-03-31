//
//  Previewable.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import Foundation

protocol Previewable {
    
    var previewTitle: String { get }
    var previewBody: String { get }
    var previewThumbnailUrl: String? { get }
    var previewFallbackIcon: KrakenIcon { get }
    
}

protocol PreviewableDataController: NetworkDataController {
    
    var previewItems: [Previewable] { get }
    
}

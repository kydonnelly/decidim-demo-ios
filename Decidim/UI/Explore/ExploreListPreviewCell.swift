//
//  ExploreListPreviewCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/26/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class ExploreListPreviewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var thumbnailImageView: GiphyMediaView!
    
    func setup(item: Previewable) {
        self.titleLabel.text = item.previewTitle
        self.bodyLabel.text = item.previewBody
        self.thumbnailImageView.icon = item.previewFallbackIcon
        self.thumbnailImageView.setThumbnail(url: item.previewThumbnailUrl)
    }
    
}

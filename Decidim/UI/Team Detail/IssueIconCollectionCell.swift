//
//  IssueIconCollectionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/11/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

class IssueIconCollectionCell: UICollectionViewCell {
    
    typealias ActionBlock = () -> Void
    
    @IBOutlet var iconImageView: GiphyMediaView!
    
    private var onIssueTapped: ActionBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedIssueImageView(_:)))
        self.iconImageView.addGestureRecognizer(tapGesture)
        self.iconImageView.isUserInteractionEnabled = true
    }
    
    public func setup(issue: Issue, tappedIssueBlock: ActionBlock?) {
        self.iconImageView.setThumbnail(url: issue.iconUrl)
        self.onIssueTapped = tappedIssueBlock
    }
    
}

extension IssueIconCollectionCell {
    
    @IBAction func tappedIssueImageView(_ sender: UIGestureRecognizer) {
        self.onIssueTapped?()
    }
    
}

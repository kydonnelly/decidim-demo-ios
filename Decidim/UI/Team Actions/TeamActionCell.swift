//
//  TeamActionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamActionCell: UITableViewCell {
    
    typealias UpdateBlock = () -> Void
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var statusImageView: UIImageView!
    @IBOutlet var updateButton: UIButton!
    
    private var onUpdate: UpdateBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusImageView.iconInset = 8
    }
    
    public func setup(description: String, status: TeamActionStatus, canUpdate: Bool, onUpdate: UpdateBlock?) {
        self.descriptionLabel.text = description
        
        self.onUpdate = onUpdate
        self.updateButton.isHidden = !canUpdate
        self.statusImageView.iconColor = .primaryLight
        
        switch status {
        case .done:
            self.updateButton.setTitle("Archive", for: .normal)
            self.statusImageView.icon = .clipboard
            self.statusImageView.iconBackgroundColor = .green
        case .inProgress:
            self.updateButton.setTitle("Done", for: .normal)
            self.statusImageView.icon = .circle_up
            self.statusImageView.iconBackgroundColor = .purple
        case .ongoing:
            self.updateButton.setTitle("Archive", for: .normal)
            self.statusImageView.icon = .infinite
            self.statusImageView.iconBackgroundColor = .blue
        case .pending:
            self.updateButton.setTitle("Start", for: .normal)
            self.statusImageView.icon = .circle
            self.statusImageView.iconBackgroundColor = .yellow
        case .proposed:
            self.updateButton.setTitle("Approve", for: .normal)
            self.statusImageView.icon = .hourglass
            self.statusImageView.iconBackgroundColor = .lightGray
        }
    }
    
}

extension TeamActionCell {
    
    @IBAction func tappedUpdateButton(_ sender: UIButton) {
        self.onUpdate?()
    }
    
}

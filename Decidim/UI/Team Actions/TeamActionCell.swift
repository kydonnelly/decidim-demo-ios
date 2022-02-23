//
//  TeamActionCell.swift
//  Decidim
//
//  Created by Kyle Donnelly on 8/19/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class TeamActionCell: CustomTableViewCell {
    
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
            self.statusImageView.icon = .check
            self.statusImageView.iconBackgroundColor = .systemGreen
        case .inProgress:
            self.updateButton.setTitle("Done", for: .normal)
            self.statusImageView.icon = .clipboard
            self.statusImageView.iconBackgroundColor = .systemPurple
        case .ongoing:
            self.updateButton.setTitle("Archive", for: .normal)
            self.statusImageView.icon = .folder_remove
            self.statusImageView.iconBackgroundColor = .systemBlue
        case .pending:
            self.updateButton.setTitle("Start", for: .normal)
            self.statusImageView.icon = .terminal
            self.statusImageView.iconBackgroundColor = .systemOrange
        case .proposed:
            self.updateButton.setTitle("Approve", for: .normal)
            self.statusImageView.icon = .ticket
            self.statusImageView.iconBackgroundColor = .systemRed
        case .archived:
            fallthrough
        case .unknown:
            self.updateButton.setTitle("", for: .normal)
            self.statusImageView.icon = .close_circle
            self.statusImageView.iconBackgroundColor = .clear
        }
    }
    
}

extension TeamActionCell {
    
    @IBAction func tappedUpdateButton(_ sender: UIButton) {
        self.onUpdate?()
    }
    
}

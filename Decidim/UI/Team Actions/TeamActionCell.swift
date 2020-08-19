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
        
        self.updateButton.backgroundColor = UIColor.blue
    }
    
    public func setup(description: String, status: TeamActionStatus, canUpdate: Bool, onUpdate: UpdateBlock?) {
        self.descriptionLabel.text = description
        
        self.onUpdate = onUpdate
        self.updateButton.isHidden = !canUpdate
        
        switch status {
        case .done:
            self.updateButton.setTitle("Archive", for: .normal)
            self.statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            self.statusImageView.tintColor = .green
        case .inProgress:
            self.updateButton.setTitle("Done", for: .normal)
            self.statusImageView.image = UIImage(systemName: "circle.fill")
            self.statusImageView.tintColor = .purple
        case .ongoing:
            self.updateButton.setTitle("Archive", for: .normal)
            self.statusImageView.image = UIImage(systemName: "circle")
            self.statusImageView.tintColor = .blue
        case .pending:
            self.updateButton.setTitle("Start", for: .normal)
            self.statusImageView.image = UIImage(systemName: "dot.square")
            self.statusImageView.tintColor = .yellow
        case .proposed:
            self.updateButton.setTitle("Approve", for: .normal)
            self.statusImageView.image = UIImage(systemName: "dot.square.fill")
            self.statusImageView.tintColor = .lightGray
        }
    }
    
}

extension TeamActionCell {
    
    @IBAction func tappedUpdateButton(_ sender: UIButton) {
        self.onUpdate?()
    }
    
}

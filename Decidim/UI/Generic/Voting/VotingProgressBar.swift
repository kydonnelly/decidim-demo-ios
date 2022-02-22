//
//  VotingProgressBar.swift
//  Decidim
//
//  Created by Kyle Donnelly on 2/21/22.
//  Copyright © 2022 Kyle Donnelly. All rights reserved.
//

import UIKit

public class VotingProgressBar: UIView {
    
    private var fillView: UIView!
    private var fillWidthConstraint: NSLayoutConstraint!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        self.fillView = UIView(frame: .zero)
        self.addSubview(self.fillView)
        self.fillView.translatesAutoresizingMaskIntoConstraints = false
        self.fillWidthConstraint = self.fillView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0)
        self.addConstraints([self.fillWidthConstraint,
                             self.fillView.topAnchor.constraint(equalTo: self.topAnchor),
                             self.fillView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                             self.fillView.heightAnchor.constraint(equalTo: self.heightAnchor)])
        
        self.layer.masksToBounds = true
        self.fillView.layer.masksToBounds = true
    }
    
    public func setup(percentage: CGFloat, color: UIColor) {
        self.fillView.backgroundColor = color
        
        self.removeConstraint(self.fillWidthConstraint)
        self.fillWidthConstraint = self.fillView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: percentage)
        self.addConstraint(self.fillWidthConstraint)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // pill shape
        self.layer.cornerRadius = self.bounds.size.height * 0.5
        self.fillView.layer.cornerRadius = self.bounds.size.height * 0.5
    }
    
}

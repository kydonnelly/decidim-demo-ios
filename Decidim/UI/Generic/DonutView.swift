//
//  DonutView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 3/7/21.
//  Copyright © 2021 Kyle Donnelly. All rights reserved.
//

import UIKit

struct DonutSlice {
    let name: String
    let color: UIColor
    let weight: CGFloat
}

class DonutView: UIView {
    
    private static let ninetyDegreesRadians = CGFloat.pi * 0.5
    private static let threeSixtyDegreesRadians = CGFloat.pi * 2.0
    
    @IBInspectable public var strokeWidth: CGFloat = 1.0
    
    private var slices: [DonutSlice] = []
    
    public override var isOpaque: Bool {
        get { return false }
        set { }
    }
    
    public func setup(slices: [DonutSlice]) {
        self.slices = slices
        self.setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    private var totalWeight: CGFloat {
        return self.slices.reduce(0) { $0 + $1.weight }
    }
    
    private func drawArc(context: CGContext, startRatio: CGFloat, endRatio: CGFloat, color: UIColor) {
        context.addArc(center: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
                       radius: 0.5 * (self.bounds.size.width - self.strokeWidth),
                       startAngle: startRatio * Self.threeSixtyDegreesRadians - Self.ninetyDegreesRadians,
                       endAngle: endRatio * Self.threeSixtyDegreesRadians - Self.ninetyDegreesRadians,
                       clockwise: false)
        
       context.setFillColor(color.cgColor)
       context.setStrokeColor(color.cgColor)
       context.setLineWidth(self.strokeWidth)
       
       context.drawPath(using: .stroke)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let totalWeight = self.totalWeight
        if totalWeight > 0 {
            var drawnWeights: CGFloat = 0.0
            self.slices.forEach {
                let startRatio = drawnWeights / totalWeight
                drawnWeights += $0.weight
                let endRatio = drawnWeights / totalWeight
                self.drawArc(context: context, startRatio: startRatio, endRatio: endRatio, color: $0.color)
            }
        } else {
            self.drawArc(context: context, startRatio: 0.0, endRatio: 1.0, color: .lightGray)
        }
    }
    
}

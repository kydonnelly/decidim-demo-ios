//
//  GradientView.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

public class LinearGradientView : UIView {
    
    public enum Direction: Int {
        case vertical, horizontal
    }
    
    @IBInspectable private var startColor: UIColor?
    @IBInspectable private var endColor: UIColor?
    @IBInspectable private var direction: Int = 0
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        if let start = self.startColor, let end = self.endColor,
           let dir = Direction(rawValue: self.direction) {
            self.update(colors: [start, end], direction: dir)
        }
    }
    
    override public class var layerClass: AnyClass {
        get {
            return LinearGradientLayer.self
        }
    }
    
    private var gradientLayer: LinearGradientLayer {
        get {
            return self.layer as! LinearGradientLayer
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.gradientLayer.needsDisplayOnBoundsChange = true
    }
    
    public func update(colors: [UIColor], direction: Direction) {
        self.gradientLayer.colors = colors
        self.gradientLayer.direction = direction
        self.gradientLayer.setNeedsDisplay()
    }
    
    public func setupWithRandomColors(seed: Int, direction: Direction) {
        let randomRed = CGFloat(seed * 117 % 256) / 256.0
        let randomBlue = CGFloat(seed * 233 % 256) / 256.0
        let randomGreen = CGFloat(seed * 173 % 256) / 256.0
        let startColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        let endColor = UIColor(red: randomRed * 0.5, green: randomGreen * 0.5, blue: randomBlue * 0.5, alpha: 1.0)
        
        self.update(colors: [startColor, endColor], direction: direction)
    }
    
}

fileprivate class LinearGradientLayer : CALayer {
    
    var colors: [UIColor] = []
    var direction: LinearGradientView.Direction = .vertical
    
    private var startPoint: CGPoint {
        switch self.direction {
        case .horizontal:
            return CGPoint(x: 0.0, y: 0.5)
        case .vertical:
            return CGPoint(x: 0.5, y: 0.0)
        }
    }
    
    private var endPoint: CGPoint {
        switch self.direction {
        case .horizontal:
            return CGPoint(x: 1.0, y: 0.5)
        case .vertical:
            return CGPoint(x: 0.5, y: 1.0)
        }
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        
        let numLocations = self.colors.count
        guard numLocations > 0 else {
            return
        }
        
        ctx.saveGState()
        defer { ctx.restoreGState() }
        
        let locations = [CGFloat](stride(from: 0.0, through: 1.0, by: 1.0 / CGFloat(numLocations - 1)))
        let cgColors = self.colors.map { $0.cgColor }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations) else {
            return
        }
        
        let absoluteSize = self.bounds.size
        
        let absoluteStartPoint = CGPoint(x: absoluteSize.width * self.startPoint.x,
                                         y: absoluteSize.height * self.startPoint.y)
        
        let absoluteEndPoint = CGPoint(x: absoluteSize.width * self.endPoint.x,
                                       y: absoluteSize.height * self.endPoint.y)
        
        ctx.drawLinearGradient(gradient, start: absoluteStartPoint, end: absoluteEndPoint, options: [])
    }
    
}

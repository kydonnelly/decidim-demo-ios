//
//  OptionsBar.swift
//  Decidim
//
//  Created by Kyle Donnelly on 9/7/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class OptionsBar: UIView {
    
    static private let cellId = "Cell"
    
    typealias UpdateBlock = (Int) -> Void
    
    @IBOutlet var tableView: UITableView!
    private var cellUnderlineView: UIView!
    
    private var options: [String] = []
    private var selectedIndex: Int?
    private var selectionBlock: UpdateBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupUnderline()
        
        self.tableView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -0.5)
        self.tableView.register(UINib(nibName: "OptionsBarCell", bundle: .main),
                                forCellReuseIdentifier: Self.cellId)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.tableView.bringSubviewToFront(self.cellUnderlineView)
        self.reload(animated: false)
    }
    
    public func setup(options: [String], selectedIndex: Int?, onSelection: UpdateBlock?) {
        self.options = options
        self.selectedIndex = selectedIndex
        self.selectionBlock = onSelection
    }
    
    public func updateSelectedIndex(_ index: Int, animated: Bool) {
        self.selectedIndex = index
        
        self.tableView.reloadData()
        self.refresh(animated: animated)
        
        self.selectionBlock?(index)
    }
    
}

extension OptionsBar {
    
    fileprivate func setupUnderline() {
        self.cellUnderlineView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 4))
        self.cellUnderlineView.backgroundColor = UIColor.action
        self.cellUnderlineView.alpha = 0
        self.cellUnderlineView.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        
        let underlineSize = self.cellUnderlineView.bounds.size
        self.tableView.addSubview(self.cellUnderlineView)
        self.cellUnderlineView.center = CGPoint(x: underlineSize.height * 0.5, y: 0)
        self.cellUnderlineView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
    }
    
    fileprivate func reload(animated: Bool) {
        // reload selection options
        self.tableView.reloadData()
        
        // update cell widths
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
        self.refresh(animated: false)
    }
    
    fileprivate func refresh(animated: Bool) {
        let duration = animated ? 0.3 : 0
        
        guard let index = self.selectedIndex else {
            UIView.animate(withDuration: duration) {
                self.cellUnderlineView.alpha = 0
            }
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
        let cellRect = self.tableView.rectForRow(at: indexPath)
        let underlineWidth = max(48, cellRect.size.height - 48)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.cellUnderlineView.alpha = 1
            
            var underlineFrame = self.cellUnderlineView.frame
            underlineFrame.size.height = underlineWidth
            underlineFrame.origin.y = cellRect.midY - underlineWidth * 0.5
            self.cellUnderlineView.frame = underlineFrame
        }, completion: nil)
    }
    
}

extension OptionsBar: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.bounds.size.width / CGFloat(self.options.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Self.cellId, for: indexPath) as! OptionsBarCell
        
        let option = self.options[indexPath.row]
        let isSelected = self.selectedIndex == indexPath.row
        cell.setup(title: option, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateSelectedIndex(indexPath.row, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
    }
    
}
